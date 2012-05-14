(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyTable = MFile_common.MyTable

module Signals = struct

  let on_item_img_upload_call, on_item_img_upload = Sig.make (Run.list_iter identity)
  let on_item_doc_upload_call, on_item_doc_upload = Sig.make (Run.list_iter identity)

end

let erase_if_still_temp =   
  let task = Task.register "file.erase-temp" IFile.fmt begin fun id _ ->
    let! _ = ohm $
      MyTable.transaction id (MyTable.remove_if (fun f -> f # k = `Temp))
    in
    return (Task.Finished id)
  end in
  MModel.Task.delay 600.0 task

let _do_prepare ~usr ~lift ?ins ?item () =   
  let id = IFile.gen () in
  let file = object
    method t        = `File
    method k        = `Temp
    method usr      = IUser.decay usr
    method ins      = BatOption.map IInstance.decay ins
    method key      = IFile.to_id id
    method name     = None
    method item     = BatOption.map IItem.decay item 
    method versions = []
  end in

  (* La verification a eu lieu *)
  let real_id = lift id in
  
  let! _ = ohm $ MyTable.transaction id (MyTable.insert file) in
  let! _ = ohm $ erase_if_still_temp id in
  return real_id

let prepare_pic ~usr = 
      
  let! used, free = ohm $ MFile_usage.user usr in
    
  if used >= free then 
    return None
  else 
    let! id = ohm $ _do_prepare ~usr ~lift:IFile.Assert.put_pic () in
    return $ Some id

let prepare_if_allowed ~ins ~prepare = 

  let  see_usage_ins = IInstance.Deduce.can_see_usage ins in
  let! used, free = ohm $ MFile_usage.instance see_usage_ins in
  
  if used >= free then 
    return None
  else
    let! id = ohm $ prepare in
    return $ Some id

let prepare_client_pic ~ins ~usr = 
  prepare_if_allowed ~ins
    ~prepare:(_do_prepare ~lift:IFile.Assert.put_pic ~usr ~ins ())

let prepare_img ~ins ~usr ~item = 
  prepare_if_allowed ~ins
    ~prepare:(_do_prepare ~lift:IFile.Assert.put_img ~usr ~ins ~item ())

let prepare_doc ~ins ~usr ~item = 
  prepare_if_allowed ~ins
    ~prepare:(_do_prepare ~lift:IFile.Assert.put_doc ~usr ~ins ~item ())

let configure id ?filename ~redirect = 
  ConfigS3.upload 
    ~bucket:"ro-temp"
    ~key:(IFile.to_string id ^ "/" ^ MFile_common.string_of_version `Original)
    ?filename
    ~redirect
    ()

let _resize ~crop ~w ~h file = 
  let out = Filename.temp_file "" ".png" in
  let cmd = 
    if crop then 
      Printf.sprintf
	"convert %s -resize '%dx%d^' -gravity Center -extent '%dx%d' %s"
	(Filename.quote file)
	w h w h 
	(Filename.quote out)
    else
      Printf.sprintf
	"convert %s -resize '%dx%d>' %s"
	(Filename.quote file)
	w h 
	(Filename.quote out)      
  in
  logreq "File._resize_picture: %s" cmd ;
  let result = Sys.command cmd in
  if result = 0 then Some out else (log "Resize %s failed!" file ; None)
  
let _resize_small_pic file = 
  _resize ~w:50 ~h:50 ~crop:true file
  
let _resize_large_pic file = 
  _resize ~w:230 ~h:350 ~crop:false file

let _resize_small_img file = 
  _resize ~w:178 ~h:128 ~crop:true file

let _resize_large_img file = 
  _resize ~w:700 ~h:700 ~crop:false file

let remove ~version id = 

  let remove file = 
    try 
      let vstr     = MFile_common.string_of_version version in 
      let bucket   =
	match
	  (file # k : [`Temp|`Extern|`Doc|`Image|`Picture]),
	  (version : MFile_common.version)
	with 
	  (* temporary and original files remain in temp bucket *)
	  | `Temp, _ | _,  `Original -> Some "ro-temp"
	    
	  (* external files have no bucket *)
	  | `Extern, _ -> None

	  (* Images and docs are in the "files" bucket *)
	  | `Doc, _ | `Image, _  -> Some "ro-files"

	  (* Pictures are in their own bucket *)
	  | `Picture, _ -> Some "ro-pics"
      in

      let original = List.assoc vstr (file # versions) in
      let key      = (Id.str (file # key)) ^ "/" ^ vstr ^ "/" ^ (original # name) in

      (* Removing from extern bucket always succeeds *)
      let success  = match bucket with 
	| Some bucket -> ConfigS3.delete ~bucket ~key
	| None -> true
      in

      if success then
	let versions = BatList.remove_assoc vstr (file # versions) in
	true, `put (object		
	  method t    = `File
	  method k    = file # k 
	  method usr  = file # usr
	  method ins  = file # ins
	  method key  = file # key
	  method name = file # name
	  method versions = versions 
	  method item = file # item
	end) 
      else
	false, `keep
    with Not_found -> 
      true, `keep
  in

  MyTable.transaction id (MyTable.if_exists remove) 
      
let remove_original = 
  let task = Task.register "file.rm-original" IFile.fmt begin fun id _ ->

    let! result = ohm $ remove ~version:`Original id in
    match result with 
	| Some false -> Run.of_lazy (lazy (raise (Task.Error "Amazon.S3.delete")))
	| _          -> return (Task.Finished id)

  end in
  fun id -> MModel.Task.call task id |> Run.map ignore

let define_async_resizer ~kind ~name ~bucket ~large ~small =   
  let task = Task.register ("file.resize."^name) IFile.fmt begin fun id _ ->
    
    let process file reader =       

      reader begin fun filename -> 

	(* This entire anonymous function works with the filename immediately,
	   without storing it in the returned monad, because the file is
	   assumed to be removed from memory as soon as the `reader` function 
	   disappears.
	*)

	let upload v filename = 
	  
	  let version = MFile_common.string_of_version v in 
	  let size = BatFile.size_of filename in
	  let key = Id.str (file # key) ^ "/" ^ version ^ "/" ^ Filename.basename filename in
	  let ok  = ConfigS3.publish ~bucket ~key ~file:filename in
	  
	  let update file = 
	    let versions = file # versions in
	    let versions = BatList.remove_assoc version versions in 
	    let versions = ( version , (object
	      method size = (float_of_int size) /. 1048576.
	      method name = Util.urlencode (Filename.basename filename)
	    end )) :: versions in
	    (object
	      method t    = `File
	      method k    = kind
	      method usr  = file # usr
	      method ins  = file # ins
	      method key  = file # key
	      method name = file # name
	      method versions = versions 
	      method item = file # item
	     end)
	  in
	  
	  if ok then
	    let! _ = ohm_req_or (return false) $
	      MyTable.transaction id (MyTable.update update) 
            in 
	    return true
	  else 
	    ( log "File.resize_pic: %s upload failed" (IFile.to_string id) ;
	      return false)
    
	in
	
	let small = 
	  small filename
          |> BatOption.map (upload `Small)
          |> BatOption.default (return false)      
	and large = 
	  large filename
          |> BatOption.map (upload `Large)
	  |> BatOption.default (return false)
	in 
	
	let monad = 
	  let! small_ok = ohm small in
	  let! large_ok = ohm large in
	  if small_ok && large_ok then 	    
	    let! () = ohm $ remove_original id in
	    return true
	  else
	    return false
	in

	Some monad

      end |> BatOption.default (return false)
    in

    let download_file file name =
      let bucket = "ro-temp" 
      and key = (Id.str (file # key)) ^ "/" ^ MFile_common.original ^ "/" ^ name in
      
      process file (ConfigS3.download ~bucket ~key) |> Run.map begin function 
	| true -> Task.Finished id
	| false -> Task.Failed
      end	    
    in

    let get_original file = 
      try 
	let obj = (List.assoc MFile_common.original (file # versions)) in
	download_file file (obj # name)
      with Not_found -> 
	log "File.resize: %s has no original version!" (IFile.to_string id) ; 
	return Task.Failed
    in

    let! file_opt = ohm $ MyTable.get id in

    match file_opt with 
    | Some file -> 
      if file # k = kind then get_original file else
	return ( log "File.resize: %s is not correct type" (IFile.to_string id) ; 
		 Task.Failed )
	  
    | None -> 
      return ( log "File.resize: %s not found" (IFile.to_string id) ;
	       Task.Failed )
	
  end in
  fun id -> MModel.Task.call task id |> Run.map ignore
      
let process_pic = 
  define_async_resizer
    ~kind:`Picture
    ~name:"pic"
    ~large:_resize_large_pic
    ~small:_resize_small_pic
    ~bucket:"ro-pics"

let process_img = 
  define_async_resizer
    ~kind:`Image
    ~name:"img"
    ~large:_resize_large_img 
    ~small:_resize_small_img
    ~bucket:"ro-files"

let process_doc =
  let task = Task.register "file.process.doc" IFile.fmt begin fun id _ ->
    
    let process file name =       

      let version = MFile_common.string_of_version `File in 

      let size_opt = 

	let bucket = "ro-temp" 
	and key = Id.str (file # key) ^ "/" ^ MFile_common.original ^ "/" ^ name in

	let! filename = ConfigS3.download ~bucket ~key in

	let size = BatFile.size_of filename in
	let bucket = "ro-files" 
	and key = Id.str (file # key) ^ "/" ^ version ^ "/" ^ name in

	let ok  = ConfigS3.publish ~bucket ~key ~file:filename in
	
	if ok then Some size else None

      in

      let! size = req_or (return Task.Failed) size_opt in

      let update file = 
	let versions = file # versions in
	let versions = BatList.remove_assoc version versions in 
	let versions = ( version , (object
	  method size = (float_of_int size) /. 1048576.
	  method name = name 
	end )) :: versions in
	(object
	  method t    = `File
	  method k    = `Doc 
	  method usr  = file # usr
	  method ins  = file # ins
	  method key  = file # key
	  method name = file # name
	  method versions = versions 
	  method item = file # item
	 end)
      in
	
      let! _ = ohm_req_or (return Task.Failed) $
	MyTable.transaction id (MyTable.update update)
      in

      let! () = ohm $ remove_original id in
      return (Task.Finished id)
    in

    let get_original file = 
      try 
	let obj = (List.assoc MFile_common.original (file # versions)) in
	process file (obj # name) 
      with Not_found -> 
	log "File.process-doc: %s has no original version!" (IFile.to_string id) ; 
	return Task.Failed
    in
    
    let! file = ohm_req_or (return Task.Failed) $ MyTable.get id in

    if file # k = `Doc then get_original file else
      return ( log "File.process-doc: %s is not correct type" (IFile.to_string id) ; 
	       Task.Failed )
	
  end in
  fun id -> MModel.Task.call task id |> Run.map ignore  
      
let define_async_confirmer ~kind ~name ~process = 
  let task = Task.register ("file.confirm."^name) IFile.fmt begin fun id _ ->

    let fail = return Task.Failed in 
    let success = return $ Task.Finished id in

    let transform = function 
      | None -> 
	log "File.confirm: %s does not exist" (IFile.to_string id) ; 
	false, `keep

      | Some file ->
	if file # k <> `Temp then
	  ( log "File.confirm: %s expected to be Temp" (IFile.to_string id) ; 
	    false, `keep )
	else 
	  let bucket = "ro-temp"
	  and prefix = Id.str (file # key) ^ "/" ^ MFile_common.original in
	  match ConfigS3.find_upload ~bucket ~prefix with 
	    | None -> 
	      log "File.confirm: %s : %s/%s/* was not uploaded" 
		(IFile.to_string id) bucket prefix ;
	      false, `keep
	    | Some found ->	      	     
	      if found.ConfigS3.name = "" then
		( log "File.confirm: %s has no name!" (IFile.to_string id) ; 
		  false, `keep )
	      else
		true, `put (object 
		  method t    = `File
		  method k    = kind
		  method usr  = file # usr
		  method ins  = file # ins
		  method key  = file # key
		  method item = file # item
		  method name = Some found.ConfigS3.name
		  method versions = [ MFile_common.original , (object
		    method size = (float_of_int found.ConfigS3.size) /. 1048576.
		    method name = Util.urlencode found.ConfigS3.name
		  end )]
		end) 
    in
    
    let! update_succeeded = ohm $
      MyTable.transaction id (fun id -> MyTable.get id |> Run.map transform)
    in

    let! () = true_or fail update_succeeded in
   
    let! () = ohm $ process id in

    let! file = ohm_req_or fail $ MyTable.get id in
    let! item = req_or success (file # item) in

    let! () = ohm begin
      match file # k with 

	| `Image -> 
	  Signals.on_item_img_upload_call item

	| `Doc -> 
	  
	  let! name = req_or (return ()) (file # name) in
	  let ext = MFile_extension.extension_of_file name in
	 
	  let size =
	    match file # versions with 
	      | []            -> 0.
	      | (_,info) :: _ -> info # size
	  in

	  Signals.on_item_doc_upload_call (item, name, ext, size, id) 

	| _ -> return ()
    end in 

    success

  end in
  fun id -> MModel.Task.call task (IFile.decay id) |> Run.map ignore

let confirm_pic = 
  define_async_confirmer ~kind:`Picture ~name:"pic" ~process:process_pic
    
let confirm_img = 
  define_async_confirmer ~kind:`Image ~name:"img" ~process:process_img
     
let confirm_doc =
  define_async_confirmer ~kind:`Doc ~name:"doc" ~process:process_doc
