(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Tbl = MOldFile_common.Tbl

module Signals = struct

  let on_item_img_upload_call, on_item_img_upload = Sig.make (Run.list_iter identity)
  let on_item_doc_upload_call, on_item_doc_upload = Sig.make (Run.list_iter identity)

end

let erase_if_still_temp =   
  let task = O.async # define "file.erase-temp" IOldFile.fmt 
    (fun id -> Tbl.delete_if id (#k |- (=) `Temp))
  in
  task ~delay:600.

let _do_prepare ~usr ~lift ?iid ?item () =   
  let id = IOldFile.gen () in
  let file = object
    method t        = `File
    method k        = `Temp
    method usr      = IUser.decay usr
    method ins      = BatOption.map IInstance.decay iid
    method key      = IOldFile.to_id id
    method name     = None
    method item     = BatOption.map IItem.decay item 
    method versions = []
  end in

  (* La verification a eu lieu *)
  let real_id = lift id in
  
  let! () = ohm $ Tbl.set id file in 
  let! () = ohm $ erase_if_still_temp id in
  return real_id

let prepare_pic ~cuid = 
  
  let usr = IUser.Deduce.is_anyone cuid in
    
  let! used, free = ohm $ MOldFile_usage.user usr in
    
  if used >= free then 
    return None
  else 
    let! id = ohm $ _do_prepare ~usr ~lift:IOldFile.Assert.put_pic () in
    return $ Some id

let prepare_if_allowed ~iid ~prepare = 

  let  see_usage_ins = IInstance.Deduce.can_see_usage iid in
  let! used, free = ohm $ MOldFile_usage.instance see_usage_ins in
  
  if used >= free then 
    return None
  else
    let! id = ohm $ prepare in
    return $ Some id

let prepare_client_pic ~iid ~cuid =
  let usr = IUser.Deduce.is_anyone cuid in 
  prepare_if_allowed ~iid
    ~prepare:(_do_prepare ~lift:IOldFile.Assert.put_pic ~usr ~iid ())

let prepare_img ~ins ~usr ~item = 
  prepare_if_allowed ~iid:ins
    ~prepare:(_do_prepare ~lift:IOldFile.Assert.put_img ~usr ~iid:ins ~item ())

let prepare_doc ~ins ~usr ?item () = 
  prepare_if_allowed ~iid:ins
    ~prepare:(_do_prepare ~lift:IOldFile.Assert.put_doc ~usr ~iid:ins ?item ())

let configure id ?filename ~redirect = 
  ConfigS3.upload 
    ~bucket:"ro-temp"
    ~key:(IOldFile.to_string id ^ "/" ^ MOldFile_common.string_of_version `Original)
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
      let vstr     = MOldFile_common.string_of_version version in 
      let bucket   =
	match
	  (file # k : [`Temp|`Extern|`Doc|`Image|`Picture]),
	  (version : MOldFile_common.version)
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

  Tbl.transact id (function 
    | None -> return (None, `keep)
    | Some file -> let success, what = remove file in 
		   return (Some success, what))

      
let remove_original = 
  let task = O.async # define "file.rm-original" IOldFile.fmt 
    begin fun id ->

      let! result = ohm $ remove ~version:`Original id in
      match result with 
	| Some false -> Run.of_lazy (lazy (raise Async.Reschedule))
	| _          -> return ()

    end in
  fun id -> task id

let define_async_resizer ~kind ~name ~bucket ~large ~small =   
  let task = O.async # define ("file.resize."^name) IOldFile.fmt begin fun id   ->
    
    let process file reader =       

      reader begin fun filename -> 

	(* This entire anonymous function works with the filename immediately,
	   without storing it in the returned monad, because the file is
	   assumed to be removed from memory as soon as the `reader` function 
	   disappears.
	*)

	let upload v filename = 
	  
	  let version = MOldFile_common.string_of_version v in 
	  let size = BatFile.size_of filename in
	  let key = Id.str (file # key) ^ "/" ^ version ^ "/" ^ Filename.basename filename in
	  let ok  = ConfigS3.publish ~bucket ~key ~file:filename in
	  
	  let update file = 
	    let versions = file # versions in
	    let versions = BatList.remove_assoc version versions in 
	    let versions = ( version , (object
	      method size = (float_of_int size) /. 1048576.
	      method name = Netencoding.Url.encode ~plus:false (Filename.basename filename)
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
	    let! () = ohm $ Tbl.update id update in 
	    return true
	  else 
	    ( log "File.resize_pic: %s upload failed" (IOldFile.to_string id) ;
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
      and key = (Id.str (file # key)) ^ "/" ^ MOldFile_common.original ^ "/" ^ name in
      
      let! _ = ohm $ process file (ConfigS3.download ~bucket ~key) in
      return ()	    
    in

    let get_original file = 
      try 
	let obj = (List.assoc MOldFile_common.original (file # versions)) in
	download_file file (obj # name)
      with Not_found -> 
	return (log "File.resize: %s has no original version!" (IOldFile.to_string id)) 
    in

    let! file_opt = ohm $ Tbl.get id in

    match file_opt with 
      | Some file -> 
	if file # k = kind then get_original file else
	  return ( log "File.resize: %s is not correct type" (IOldFile.to_string id) )
	    
      | None -> 
	return ( log "File.resize: %s not found" (IOldFile.to_string id) )
	
  end in
  fun id -> task id
      
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
  let task = O.async # define "file.process.doc" IOldFile.fmt begin fun id ->
    
    let process file name =       

      let version = MOldFile_common.string_of_version `File in 

      let size_opt = 

	let bucket = "ro-temp" 
	and key = Id.str (file # key) ^ "/" ^ MOldFile_common.original ^ "/" ^ name in

	let! filename = ConfigS3.download ~bucket ~key in

	let size = BatFile.size_of filename in
	let bucket = "ro-files" 
	and key = Id.str (file # key) ^ "/" ^ version ^ "/" ^ name in

	let ok  = ConfigS3.publish ~bucket ~key ~file:filename in
	
	if ok then Some size else None

      in

      let! size = req_or (return ()) size_opt in

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
	
      let! () = ohm $ Tbl.update id update in
      let! () = ohm $ remove_original id in
      return ()

    in

    let get_original file = 
      try 
	let obj = (List.assoc MOldFile_common.original (file # versions)) in
	process file (obj # name) 
      with Not_found -> 
	return (log "File.process-doc: %s has no original version!" (IOldFile.to_string id))
    in
    
    let! file = ohm_req_or (return ()) $ Tbl.get id in

    if file # k = `Doc then get_original file else
      return (log "File.process-doc: %s is not correct type" (IOldFile.to_string id))
	
  end in
  fun id -> task id 
      
let define_async_confirmer ~kind ~name ~process = 
  let task = O.async # define ("file.confirm."^name) IOldFile.fmt begin fun id ->

    let fail = return () in
    let success = return () in

    let transform = function 
      | None -> 
	log "File.confirm: %s does not exist" (IOldFile.to_string id) ; 
	false, `keep

      | Some file ->
	if file # k <> `Temp then
	  ( log "File.confirm: %s expected to be Temp" (IOldFile.to_string id) ; 
	    false, `keep )
	else 
	  let bucket = "ro-temp"
	  and prefix = Id.str (file # key) ^ "/" ^ MOldFile_common.original in
	  match ConfigS3.find_upload ~bucket ~prefix with 
	    | None -> 
	      log "File.confirm: %s : %s/%s/* was not uploaded" 
		(IOldFile.to_string id) bucket prefix ;
	      false, `keep
	    | Some found ->	      	     
	      if found.ConfigS3.name = "" then
		( log "File.confirm: %s has no name!" (IOldFile.to_string id) ; 
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
		  method versions = [ MOldFile_common.original , (object
		    method size = (float_of_int found.ConfigS3.size) /. 1048576.
		    method name = Netencoding.Url.encode ~plus:false found.ConfigS3.name
		  end )]
		end) 
    in
    
    let! update_succeeded = ohm $ Tbl.transact id (transform |- return) in

    let! () = true_or fail update_succeeded in
   
    let! () = ohm $ process id in

    let! file = ohm_req_or fail $ Tbl.get id in

    match file # k with 
	
      | `Image -> let! item = req_or success (file # item) in
		  Signals.on_item_img_upload_call item
		    
      | `Doc -> let! name = req_or success (file # name) in
		let ext = MOldFile_extension.extension_of_file name in
		
		let size =
		  match file # versions with 
		    | []            -> 0.
		    | (_,info) :: _ -> info # size
		in
		
		Signals.on_item_doc_upload_call (file # item, name, ext, size, id) 
		  
      | _ -> success

  end in
  fun id -> task (IOldFile.decay id) 

let confirm_pic = 
  define_async_confirmer ~kind:`Picture ~name:"pic" ~process:process_pic
    
let confirm_img = 
  define_async_confirmer ~kind:`Image ~name:"img" ~process:process_img
     
let confirm_doc =
  define_async_confirmer ~kind:`Doc ~name:"doc" ~process:process_doc
