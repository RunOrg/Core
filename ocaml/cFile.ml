(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let pic_formats = [ "image/jpeg" ; 
		    "image/gif" ;
		    "image/png" ;
		    "image/tiff" ]

let format make_token from_token = 

  let to_string cuid id = 
    let proof = make_token cuid id in
    IFile.to_string id ^ "-" ^ proof 
  in

  let get_fmt cuid = 
    let of_json json = 
      try let str = Json_type.Browse.string json in 
	  let (id,proof) = BatString.split str "-" in
	  let id = IFile.of_string id in 
	  from_token cuid id proof 
      with _ -> None
    in
    
    let to_json id = 
      Json_type.Build.string (to_string cuid id) 
    in
    
    { Fmt.to_json = to_json ; Fmt.of_json = of_json }
  in
  
  let of_string cuid str = 
    let json = Json_type.Build.string str in 
    (get_fmt cuid).Fmt.of_json json 
  in

  to_string, get_fmt, of_string

(* The format for converting to and from a put-doc identifier ------------------------------ *)

let string_of_get_doc, get_doc_fmt, get_doc_of_string = 
  format IFile.Deduce.make_getDoc_token IFile.Deduce.from_getDoc_token

(* The format for converting to and from a put-pic identifier ------------------------------ *)

let string_of_get_pic, get_pic_fmt, get_pic_of_string = 
  format IFile.Deduce.make_getPic_token IFile.Deduce.from_getPic_token

(* The format for converting to and from a get-img identifier ------------------------------ *)

let string_of_get_img, get_img_fmt, get_img_of_string = 
  format IFile.Deduce.make_getImg_token IFile.Deduce.from_getImg_token

(* Find a picture and return id ------------------------------------------------------------ *)

let return_pic cuid request response = 

  let return file = 
    return 
      (Action.json 
	 ["val", Json_type.Build.optional Json_type.Build.string file] response)
  in

  let fail = return None in 
 
  let! id = req_or fail (request # post "id") in
  
  let! view = req_or fail (get_pic_of_string cuid id) in 

  let! url = ohm (MFile.Url.get view `Small) in

  return url 

(* CConfirm a picture ----------------------------------------------------------------------- *)

let confirm_pic cuid request response = 

  let white = return (Action.html identity response) in
  
  let! raw_id = req_or white (request # args 0) in
  let! id     = req_or white (get_pic_of_string cuid raw_id) in
  let! _      = ohm (MFile.Upload.confirm_pic id) in

  white

(* CConfirm an image ------------------------------------------------------------------------ *)

let confirm_img cuid success fail request = 

  let! raw_id = req_or fail (request # args 0) in
  let! id     = req_or success (get_img_of_string cuid raw_id) in
  let! _      = ohm (MFile.Upload.confirm_img id) in

  success

(* CConfirm a document ---------------------------------------------------------------------- *)

let confirm_doc cuid request response = 

  let white = return (Action.html identity response) in
  
  let! raw_id = req_or white (request # args 0) in
  let! id     = req_or white (get_doc_of_string cuid raw_id) in
  let! _      = ohm (MFile.Upload.confirm_doc id) in

  white

(* CPicture upload form --------------------------------------------------------------------- *)

let () = CCore.User.register UrlFile.Core.put_pic begin fun i18n cuid request response -> 

  let title = `label "picUploader.title" in
  let fail  =
    CCore.render
      (return (I18n.get i18n title))
      (return identity) 
      response
  in

  let uid = IUser.Deduce.is_self cuid in
  let cuid = ICurrentUser.Deduce.is_unsafe cuid in 
    
  let! id = ohm_req_or fail $ MFile.Upload.prepare_pic ~usr:uid in
  
  let redirect = (UrlFile.Core.ok_pic ()) # build
    (string_of_get_pic cuid (IFile.Deduce.get_pic id))
  in
  
  let body  = 
    return (
      VFile.form
	~cancel:(UrlCore.cancel # build)
	~upload:(MFile.Upload.configure id redirect)
	~formats:pic_formats
	~i18n 	
    )
  in
  
  CCore.render (return (I18n.get i18n title)) body response

end

(* Pic confirm endpoint --------------------------------------------------------------------- *)

let () = CCore.User.register (UrlFile.Core.ok_pic ()) begin fun i18n cuid request response ->

  let cuid = ICurrentUser.Deduce.is_unsafe cuid in
  confirm_pic cuid request response

end

(* Pic find endpoint ------------------------------------------------------------------------ *)

let () = CCore.User.register UrlFile.Core.get_pic begin fun i18n cuid request response ->

  let cuid = ICurrentUser.Deduce.is_unsafe cuid in 
  return_pic cuid request response

end

(* Pic uploader component ------------------------------------------------------------------- *)

let pic_uploader i18n id name =   
  VFile.pic_uploader 
    ~url_put:(UrlFile.Core.put_pic # build)
    ~url_get:(UrlFile.Core.get_pic # build)
    ~id
    ~name
    ~i18n

(* CPicture upload form [Client] ------------------------------------------------------------ *)

let () = CClient.User.register CClient.is_admin UrlFile.Client.put_pic begin fun ctx request response -> 

    let title = `label "upload.title" in
    let i18n  = ctx # i18n in

    let fail  = 
      CCore.render 
	~title:(return (I18n.get i18n title))
	~body:(return identity) 
	response 
    in
    
    let uid   = IIsIn.user (ctx # myself) in
    let iid   = IInstance.Deduce.admin_upload (IIsIn.instance ctx # myself) in

    let usr   = IUser.Deduce.unsafe_is_anyone uid in
    
    let! id = ohm_req_or fail $ MFile.Upload.prepare_client_pic ~ins:iid ~usr in
    
    let redirect = (UrlFile.Client.ok_pic ()) # build (ctx # instance) 
      (string_of_get_pic uid (IFile.Deduce.get_pic id))
    in
    
    let body  = 
      return (
	VFile.form
	  ~cancel:(UrlClient.cancel # build (ctx # instance))
	  ~upload:(MFile.Upload.configure id redirect)
	  ~formats:pic_formats
	  ~i18n 
      )
    in
    
    CCore.render ~title:(return (I18n.get i18n title)) ~body response

end

(* Pic confirm endpoint [Client] ------------------------------------------------------------ *)

let () = CClient.User.register CClient.is_contact (UrlFile.Client.ok_pic ()) begin fun ctx request response ->  

  let cuid = IIsIn.user (ctx # myself) in
  confirm_pic cuid request response 

end

(* Pic find endpoint [Client] --------------------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact UrlFile.Client.get_pic begin fun ctx request response ->

  let cuid = IIsIn.user (ctx # myself) in 
  return_pic cuid request response 

end

(* Pic uploader component ------------------------------------------------------------------- *)

let client_pic_uploader instance i18n id name = 
  VFile.pic_uploader 
    ~url_put:(UrlFile.Client.put_pic # build instance)
    ~url_get:(UrlFile.Client.get_pic # build instance)
    ~id
    ~name
    ~i18n

(* CImage uploader configuration [Client] -------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact (UrlFile.Client.put_img ()) 
  begin fun ctx request response ->

    let cuid = IIsIn.user (ctx # myself) in
    
    let return upload confirm post = return 
      (Action.json [ "confirm", Json_type.Build.string confirm ;
		     "upload", Json_type.Build.string upload ;
		     "post", Json_type.Build.objekt 
		       (List.map (fun (k,v) -> k, Json_type.Build.string v) post)
		   ] response)
    in 
    
    let fail = return "" "" [] in
    
    let! filename = req_or fail (request # post "name") in
    
    let! album_id = req_or fail (request # args 0) in
    
    let! album_opt = ohm (MAlbum.try_get ctx (IAlbum.of_string album_id)) in
    
    let! album_write = ohm_req_or fail (Run.opt_bind MAlbum.Can.write album_opt) in
    
    let! (item, file) = ohm_req_or fail (MItem.Create.image ctx album_write) in
    
    let upload_config = MFile.Upload.configure file ~filename ~redirect:"-" in
    
    let upload_url, upload_post = ConfigS3.upload_url upload_config in
    
    let confirm_url =
      (UrlFile.Client.ok_img ()) # build (ctx # instance)
	(string_of_get_img cuid (IFile.Deduce.get_img file)) 
    in
    
    return upload_url confirm_url upload_post
      
  end

(* Img confirm endpoint [Client] -------------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact (UrlFile.Client.ok_img ()) 
  begin fun ctx request response ->  
    
    let cuid = IIsIn.user (ctx # myself) in
    let fail = CCore.js_fail_message (ctx # i18n) "changes.error" response in 
    let success = CCore.js_fail_message (ctx # i18n) "changes.soon" response in 
    confirm_img cuid success fail request 
      
  end

(* Doc confirm endpoint [Client] ----------------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact (UrlFile.Client.ok_doc ())
  begin fun ctx request response ->  
    
    let cuid = IIsIn.user (ctx # myself) in
    confirm_doc cuid request response
      
  end

(* Document upload form -------------------------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact (UrlFile.Client.put_doc ()) begin
  fun ctx request response -> 

    let title = `label "upload.title" in
    let i18n  = ctx # i18n in
    
    let forbidden = 
      CCore.render 
	~title:(return (I18n.get i18n title))
	~body:(return (VFile.Forbidden.render () i18n))
	response 
    in
    
    let uid   = IIsIn.user (ctx # myself) in

    let! folder_id = req_or forbidden (request # args 0) in
    
    let! folder_opt = ohm (MFolder.try_get ctx (IFolder.of_string folder_id)) in
    
    let! folder_write = ohm_req_or forbidden
      (Run.opt_bind MFolder.Can.write folder_opt) 
    in

    let full =
      CCore.render 
	~title:(return (I18n.get i18n title))
	~body:begin
	  
	  let ins = 
	    IInstance.Deduce.can_see_usage 
	      (MFolder.Get.write_instance folder_write)
	  in 
	  
	  let! (used, free) = ohm (MFile.Usage.instance ins) in
	
	  if used >= free then
	    return (VFile.Excess.render (used,free) i18n)
	  else
	    return (VFile.Error.render () i18n)

	end 
	response 
    in
    
    let! (item, file) = ohm_req_or full (MItem.Create.doc ctx folder_write) in
    
    let redirect = (UrlFile.Client.ok_doc ()) # build (ctx # instance) 
      (string_of_get_doc uid (IFile.Deduce.get_doc file))
    in
	
    let body  = 
      return (
	VFile.form
	  ~cancel:(UrlClient.cancel # build (ctx # instance))
	  ~upload:(MFile.Upload.configure file redirect)
	  ~formats:[]
	  ~i18n 
      )
    in
    
    CCore.render ~title:(return (I18n.get i18n title)) ~body response
  
end
