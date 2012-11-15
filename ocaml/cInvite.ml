(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let by_name kind back access gid render = 

  let  how = match kind with 
    | `Group | `Forum -> `Add
    | `Event -> `Invite
  in

  let! submit = ohm $ AdLib.get (`Import_ByName_Submit how) in

  let config = object
    method submit = submit
    method search = Action.url UrlClient.Search.avatars (access # instance # key) () 
  end in 

  render $ Asset_Invite_ByName.render config

(* Handling by-group invitations ------------------------------------------------------------------- *)

module ByGroupArgs = Fmt.Make(struct
  type json t = ( IGroup.t list )
end)

let by_group kind back access gid render = 

  let! post = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let  list = BatOption.default [] (ByGroupArgs.of_json_safe json) in
    
    let! aids = ohm $ O.decay (Run.list_map begin fun gid -> 
      let! group = ohm_req_or (return []) $ MGroup.try_get access gid in 
      let! group = ohm_req_or (return []) $ MGroup.Can.list group in 
      let! all   = ohm $ MMembership.InGroup.all (MGroup.Get.id group) `Validated in
      return (List.map snd all) 
    end list) in
    
    let aids = BatList.sort_unique compare (List.concat aids) in
    
    let! () = ohm $ O.decay begin MMembership.Mass.admin
	~from:(access # self) gid aids 
	(match kind with 
	  | `Group | `Forum -> [ `Accept true ; `Default true ] 
	  | `Event -> [ `Accept true ; `Invite ])
    end in 
    
    let delay = 5000 in
    
    return $ Action.javascript (Js.redirect ~delay ~url:back ()) res
      
  end in

  render begin 

    let! list = ohm $ O.decay (MEntity.All.get_by_kind access `Group) in
    
    let! list = ohm $ O.decay (Run.list_filter begin fun entity -> 
      
      let! name = ohm $ CEntityUtil.name entity in
      
      let! ()     = true_or (return None) (not (MEntity.Get.draft entity)) in
      let  gid'   = MEntity.Get.group entity in 
      
      let! group  = ohm_req_or (return None) $ MGroup.try_get access gid' in
      let! group  = ohm_req_or (return None) $ MGroup.Can.list group in
      let  gid'   = MGroup.Get.id group in 
      
      let! ()     = true_or (return None) (IGroup.decay gid <> IGroup.decay gid') in
      
      let! count  = ohm $ MMembership.InGroup.count gid' in
      
      if count # count = 0 then return None else 
	
	return $ Some (object
	  method id     = IGroup.to_string gid'
	  method count  = count # count
	  method name   = name
	end)
    end list) in 
    
    Asset_Invite_ByGroup.render (object
      method groups = list
      method how    = (match kind with 
	| `Group | `Forum -> `Add
	| `Event -> `Invite) 
      method url    = OhmBox.reaction_json post () 
    end)  

  end

(* Handling by-email invitations ------------------------------------------------------------------- *)

module CreateArgs = Fmt.Make(struct
  type json t = ( (string * string * string) list )
end)

let by_email back access gid render = 

  let! post = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let list = BatOption.default [] (CreateArgs.of_json_safe json) in
    
    let! () = ohm $ O.decay begin MMembership.Mass.create
	~from:(access # self) (access # iid) gid list [ `Accept true ; `Default true ] 
    end in 
    
    let delay = if List.length list < 3 then 3000 else 6000 in
    
    return $ Action.javascript (Js.redirect ~delay ~url:back ()) res
      
  end in
  
  render $ Asset_Invite_ByEmail.render (object
    method url = OhmBox.reaction_json post () 
  end)   

(* Root box -------------------------------------------------------------------------------------- *)

let box kind url back access gid wrapper = 

  let! tab = O.Box.parse UrlClient.Invite.seg in 
  let  tab = if tab = `ByEmail && kind <> `Group then `ByGroup else tab in 

  let menu = BatList.filter_map 
    (BatOption.map 
       (fun (key,label) -> 
	 (object
	   method selected = key = tab
	   method label = AdLib.write label 
	   method url = url (fst UrlClient.Invite.seg key)
	 end)))
    [ ( if kind = `Group then Some (`ByEmail, `Import_ByEmail) else None) ;
      Some (`ByGroup, `Import_ByGroup) ;
      Some (`ByName,  `Import_ByName) ]
  in 

  let render body = 
    O.Box.fill $ wrapper begin
      Asset_Invite_Tabs.render (object
	method menu = menu
	method body = body
      end)
    end 
  in
  
  match tab with 
    | `ByName  -> by_name  kind back access gid render
    | `ByGroup -> by_group kind back access gid render
    | `ByEmail -> by_email      back access gid render
  
