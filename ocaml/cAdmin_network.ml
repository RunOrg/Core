(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

open MRelatedInstance
open MRelatedInstance.Data

let string_of_time t = 
  let tm = Unix.localtime t in 
  Printf.sprintf "%02d:%02d %02d/%02d/%04d"
    (tm.Unix.tm_hour)
    (tm.Unix.tm_min)
    (tm.Unix.tm_mday)
    (tm.Unix.tm_mon + 1)
    (tm.Unix.tm_year + 1900)

let render_core data = 
  View.str "<tr><td><img style=\"width:30px\" src=\""
  |- View.esc data # from_pic
  |- View.str "\"/></td><td><div style=\"font-weight:bold;line-height:10px\">"
  |- View.esc data # from_name
  |- View.str "</div><div style=\"font-size:10px;color:#666\"/>"
  |- View.esc data # from_mail
  |- View.str "</div><div style=\"font-size:10px;color:#666\"/>"
  |- View.str data # from_where 
  |- View.str "</div></td><td><div style=\"font-size:10px;color:#666\">"
  |- View.esc (string_of_time data # time)
  |- View.str "</div></td><td>"
  |- View.implode (View.str ",<br/>") View.esc data # to_mails
  |- View.str "</td><td><div><b>"
  |- View.esc data # to_name
  |- View.str "</b></div><div style=\"font-size:10px;color:#666\"/>"
  |- View.esc (BatOption.default "(pas de site)" data # to_site) 
  |- View.str "</div></td><td><form method='POST' action='"
  |- View.esc data # form_url 
  |- View.str "'><input name='id' value='"
  |- View.esc (BatOption.default "" (BatOption.map IInstance.to_string data # iid))
  |- View.str "'/><button type=submit>Ok</button></form></td></tr>"
  |- View.str "<tr><td colspan='6'><div style='font-size:9px;color:#888;margin:0px'>"
  |- View.str (VText.format data # text)
  |- View.str "</div></td></tr>"

let instance_name i = 
  match i with None -> return "" | Some i -> 
    let! instance = ohm (MInstance.get i) in
    match instance with 
      | None -> return ""
      | Some instance -> return ("<b>"^instance # key^"</b>.runorg.com")

let avatar_email admin uid_opt = 
  let fail = return "(no email)" in
  let! uid  = req_or fail uid_opt in
  let! user = ohm_req_or fail (MUser.admin_get admin uid) in
  return (user # email) 

let read_avatar admin i18n a = 
  let! details = ohm (MAvatar.details a) in  
  let! pic     = ohm (CPicture.small (details # picture)) in
  let! where   = ohm (instance_name (details # ins)) in
  let! email   = ohm (avatar_email admin (details # who)) in
  let name = CName.get i18n details in
  return (pic, name, where, email)
	
let render_item admin i18n (riid,data) =
  match data.bind with `Bound _ -> return None | `Unbound u -> 
    
    let! from_pic, from_name, from_where, from_mail = ohm $ 
      read_avatar admin i18n data.created_by 
    in

    let  owners = u.Unbound.owners in
    let! to_mails = ohm $ Run.list_map (fun uid -> avatar_email admin (Some uid)) owners in
        
    let data = object
      method time = data.created_on 
      method to_site = u.Unbound.site 
      method to_name = u.Unbound.name 
      method text = u.Unbound.request
      method from_pic = from_pic
      method from_name = from_name
      method from_where = from_where
      method from_mail = from_mail
      method to_mails = to_mails
      method form_url = UrlAdmin.network_bind # build riid
      method iid = data.profile
    end in 

    return $ Some (render_core data)

let render admin i18n list = 
  let! views = ohm $ Run.list_filter (render_item admin i18n) list in
  return (View.concat views)
  
let () = CAdmin_common.register UrlAdmin.network begin fun i18n user request response ->
  
  let! latest = ohm Backdoor.latest in

  let! render = ohm (render user i18n latest) in
  
  let title = return (View.esc "Latest Pending Contact Requests") in
  
  let body = 
    return begin 
      View.str "<table style=\"margin:auto\">"
      |- render 
      |- View.str "</table>"
    end
  in

  CCore.render ~title ~body response  

end

let () = CAdmin_common.register UrlAdmin.network_bind begin fun i18n user request response ->

  let  fail = return response in 
  let! riid = req_or fail (request # args 0) in 
  let  riid = IRelatedInstance.of_string riid in
  
  let  iid_opt = BatOption.bind 
    (fun id -> if id = "" then None else Some (IInstance.of_string id)) 
	(request # post "id")  
  in
  
  let! () = ohm begin 
    match iid_opt with 
      | Some iid -> MRelatedInstance.Backdoor.set_profile riid iid
      | None     -> return ()
  end in

  let url = match iid_opt with 
    | None -> UrlAdmin.network # build
    | Some iid -> UrlAdmin.network_edit # build iid
  in

  return $ O.Action.redirect url response

end

(* Asso edit action ------------------------------------------------------------------------ *)

module AssoEdit = struct

  module Fields = FInstance.AdminEdit.Fields
  module Form   = FInstance.AdminEdit.Form

  let () = CAdmin_common.register UrlAdmin.network_edit_post
    begin fun i18n user request response ->

      let  fail = return response in 
      let! iid  = req_or fail (request # args 0) in 
      let  iid  = IInstance.of_string iid in
      
      let name     = ref ""
      and key      = ref ""
      and desc     = ref None
      and site     = ref None
      and pic      = ref None
      and address  = ref None
      and contact  = ref None 
      and facebook = ref None
      and twitter  = ref None
      and phone    = ref None
      and tags     = ref None 
      and visible  = ref None 
      and rss      = ref None in
      
      let form = Form.readpost (request # post)
        |> Form.mandatory `Name     Fmt.String.fmt name     
	    (i18n,`label "instance.field.name.required")
        |> Form.mandatory `Key      Fmt.String.fmt key     
	    (i18n,`label "instance.field.name.required")
	|> Form.optional  `Desc     Fmt.String.fmt desc
	|> Form.optional  `Site     Fmt.String.fmt site
	|> Form.optional  `Pic      (CFile.get_pic_fmt (ICurrentUser.Deduce.is_unsafe user)) pic
	|> Form.optional  `Address  Fmt.String.fmt address
	|> Form.optional  `Contact  Fmt.String.fmt contact
	|> Form.optional  `Facebook Fmt.String.fmt facebook
	|> Form.optional  `Twitter  Fmt.String.fmt twitter	
	|> Form.optional  `Phone    Fmt.String.fmt phone
	|> Form.optional  `Tags     Fmt.String.fmt tags
	|> Form.optional  `Visible  Fmt.Bool.fmt   visible
	|> Form.optional  `RSS      Fmt.String.fmt rss
      in      
      
      if Form.not_valid form then 
	return (O.Action.json (Form.response form) response)
      else      

	let rss = 
	  let source = BatOption.default "" !rss in
	  BatString.nsplit source "\n"
	in
      
	let tags = 
	  let source = BatOption.default "" !tags in
	  let regex  = Str.regexp "[ ,.;]+" in
	  Str.split regex source
	in
	  
	let! _ = ohm $ MInstance.Profile.Backdoor.update
	  iid
	  ~key:!key
	  ~visible:(Some true = !visible)
	  ~desc:!desc
	  ~site:!site
	  ~name:!name
	  ~address:!address
	  ~contact:!contact
	  ~facebook:!facebook
	  ~twitter:!twitter
	  ~phone:!phone
	  ~pic:(BatOption.map IFile.decay !pic)
	  ~rss
	  ~tags
	in
	
	let code = JsCode.seq [] in	
	return $ O.Action.javascript code response
    end
    
  let () = CAdmin_common.register UrlAdmin.network_edit
    begin fun i18n user request response ->

      let  fail = 
	let iid = IInstance.gen () in
	let url = UrlAdmin.network_edit # build iid in 
	return (O.Action.redirect url response)
      in 

      let! iid  = req_or fail (request # args 0) in 
      let  iid  = IInstance.of_string iid in
      
      let! profile = ohm $ MInstance.Profile.get iid in
      let  profile = BatOption.default (MInstance.Profile.empty iid) profile in 
      
      let init = FInstance.AdminEdit.Form.initialize 
	Json_type.Build.(MInstance.Profile.(begin function
	  | `Name     -> string profile # name
	  | `Desc     -> optional string profile # desc
	  | `Address  -> optional string profile # address
	  | `Pic      -> optional (CFile.get_pic_fmt (ICurrentUser.Deduce.is_unsafe user)).Fmt.to_json (profile # pic)
	  | `Site     -> optional string profile # site
	  | `Contact  -> optional string profile # contact
	  | `Facebook -> optional string profile # facebook
	  | `Twitter  -> optional string profile # twitter
	  | `Phone    -> optional string profile # phone
	  | `Tags     -> string (String.concat ", " (List.map String.lowercase profile#tags))
	  | `Key      -> string profile # key
	  | `Visible  -> bool profile # search
	  | `RSS      -> string (String.concat "\n" (List.map fst (profile # pub_rss)))
	end))
      in
      
      let body = return (
	VMe.Network.editform 
	  ~uploader:(CFile.pic_uploader)
	  ~form_url:(UrlAdmin.network_edit_post # build iid) 
	  ~form_init:init
	  ~i18n
      ) in
      
      let title = return (View.esc "Edit Instance Profile") in
      
      CCore.render ~title ~body response  
	
    end
    
end
