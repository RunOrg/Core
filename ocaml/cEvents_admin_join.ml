(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

module StatusEditFmt = Fmt.Make(struct
  type json t = <
    invite : bool option ;
    user   : bool option ;
    admin  : bool option 
  >
end)

let render_top profile status status_edit = 
  
  let gender = None in
  
  let action ?invite ?user ?admin green label = object
    method label = AdLib.write label
    method green = green 
    method url = OhmBox.reaction_json status_edit (object
      method invite = invite
      method user   = user
      method admin  = admin 
    end)
  end in
  
  let actions = match status with 
    | `NotMember -> [ action ~invite:true ~user:false ~admin:true  true  `Join_Edit_Event_Invite ;
		      action              ~user:true  ~admin:true  false `Join_Edit_Event_Add ]
    | `Declined  -> [ action              ~user:true  ~admin:true  false `Join_Edit_Event_Add ]
    | `Pending   -> [ action                          ~admin:true  true  `Join_Edit_Accept ;
		      action                          ~admin:false false `Join_Edit_Decline ]
    | `Invited   -> [ action              ~user:true  ~admin:true  false `Join_Edit_Event_Add ] 
    | `Unpaid    -> []
    | `Member    -> [ action                          ~admin:false false `Join_Edit_Remove ]
  in
  
  let status_tag = match status with 
    | `Unpaid   -> Some (`Unpaid gender)
    | `Pending  -> Some (`Pending gender)
    | `Invited  -> Some (`Invited gender)
    | `Member   -> Some (`GroupMember gender)
    | `Declined -> Some (`Declined gender)
    | `NotMember -> None
  in
  
  Asset_Join_Edit_Top.render (object
    method picture = Some (profile # pic)
    method name    = profile # name
    method status  = status_tag
    method actions = actions
  end)
    
let status_edit aid mid access group profile = fun edit _ self res ->

  let diffs = 
    ( match edit # invite with Some _ -> [ `Invite ] | None -> [] ) 
    @ ( match edit # admin with Some b -> [ `Accept b ] | None -> [] )
    @ ( match edit # user with Some b -> [ `Default b ] | None -> [] ) 
  in
  
  let gid = MGroup.Get.id group in 

  let! () = ohm $ O.decay (MMembership.admin ~from:(access # self) gid aid diffs) in
  
  let! mbr = ohm $ O.decay (MMembership.get mid) in 
  let  mbr = BatOption.default 
    (MMembership.default ~mustpay:false ~group:(IGroup.decay gid) ~avatar:aid) mbr in
  
  let! html = ohm $ render_top profile mbr.MMembership.status self in   
  return $ Action.json [ "top", Html.to_json html ] res
    
    
let () = define UrlClient.Events.def_join begin fun parents entity access -> 

  let! aid = O.Box.parse IAvatar.seg in 

  let fail = O.Box.fill begin

    let body = Asset_Event_DraftNoPeople.render (parents # edit # url) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = body
    end)

  end in 

  let  draft  = MEntity.Get.draft entity in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.write group) in
  let  group = if draft then None else group in   
  let! group = req_or fail group in 

  let! profile = ohm $ O.decay (CAvatar.mini_profile aid) in

  let! mid = ohm $ O.decay (MMembership.as_admin (MGroup.Get.id group) aid) in 

  let! status_edit = O.Box.react StatusEditFmt.fmt (status_edit aid mid access group profile) in

  O.Box.fill begin 

    let! mbr = ohm $ O.decay (MMembership.get mid) in 
    let  mbr = BatOption.default (MMembership.default ~mustpay:false ~group:gid ~avatar:aid) mbr in
    
    let body = Asset_Join_Edit.render (object
      method top = render_top profile mbr.MMembership.status status_edit
    end) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ; parents # people ] 
      method here = return (profile # name) 
      method body = body 
    end)

  end


end 
