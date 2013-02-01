(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module ByNameArgs = Fmt.Make(struct
  type json t = ( IAvatar.t list )
end)

let by_name kind back access gid render = 

  let  how = match kind with 
    | `Group -> `Add
    | `Event -> `Invite
  in

  let! post = O.Box.react Fmt.Unit.fmt begin fun _ json _ res ->

    let aids = BatOption.default [] (ByNameArgs.of_json_safe json) in

    let aids = BatList.sort_unique compare aids in
    
    let! () = ohm $ O.decay begin MMembership.Mass.admin
	~from:(access # actor) (access # iid) gid (`List aids) 
	(match kind with 
	  | `Group -> [ `Accept true ; `Default true ] 
	  | `Event -> [ `Accept true ; `Invite ])
    end in 

    let delay = 1000 + max (List.length aids * 1000) 4000 in

    return $ Action.javascript (Js.redirect ~delay ~url:back ()) res

  end in

  render begin

    let! submit = ohm $ AdLib.get (`Import_ByName_Submit how) in
    
    let config = object
      method submit = submit
      method search = Action.url UrlClient.Search.avatars (access # instance # key) () 
      method post   = OhmBox.reaction_json post () 
    end in 

    Asset_Invite_ByName.render config

  end 

(* Handling by-group invitations ------------------------------------------------------------------- *)

module ByGroupArgs = Fmt.Make(struct
  type json t = ( IAvatarSet.t list )
end)

let by_group kind back access asid render = 

  let! post = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let  list = BatOption.default [] (ByGroupArgs.of_json_safe json) in
    
    (* Only keep groups to which user has read access *) 
    let! asids = ohm $ O.decay (Run.list_filter begin fun asid -> 
      let! avset = ohm_req_or (return None) $ MAvatarSet.try_get (access # actor) asid in 
      let! avset = ohm_req_or (return None) $ MAvatarSet.Can.list avset in 
      return (Some asid) 
    end list) in

    let! () = ohm $ O.decay begin MMembership.Mass.admin
	~from:(access # actor) (access # iid) asid (`Groups (`Validated,asids))
	(match kind with 
	  | `Group -> [ `Accept true ; `Default true ] 
	  | `Event -> [ `Accept true ; `Invite ])
    end in 
    
    let delay = 5000 in
    
    return $ Action.javascript (Js.redirect ~delay ~url:back ()) res
      
  end in

  render begin 

    let! list = ohm $ MGroup.All.visible ~actor:(access # actor) (access # iid) in
    
    let! list = ohm $ O.decay (Run.list_filter begin fun group -> 
      
      let! name = ohm $ MGroup.Get.fullname group in 
      
      let  asid'  = MGroup.Get.group group in 
      
      let! avset  = ohm_req_or (return None) $ MAvatarSet.try_get (access # actor) asid' in
      let! avset  = ohm_req_or (return None) $ MAvatarSet.Can.list avset in
      let  asid'   = MAvatarSet.Get.id avset in 
      
      let! ()     = true_or (return None) (IAvatarSet.decay asid <> IAvatarSet.decay asid') in
      
      let! count  = ohm $ MMembership.InSet.count asid' in
      
      if count # count = 0 then return None else 
	
	return $ Some (object
	  method id     = IAvatarSet.to_string asid'
	  method count  = count # count
	  method name   = name
	end)
    end list) in 
    
    Asset_Invite_ByGroup.render (object
      method groups = list
      method how    = (match kind with 
	| `Group -> `Add
	| `Event -> `Invite) 
      method url    = OhmBox.reaction_json post () 
    end)  

  end

(* Handling by-email invitations ------------------------------------------------------------------- *)

module CreateArgs = Fmt.Make(struct
  type json t = ( (string * string * string) list )
end)

let by_email back access asid render = 

  let! post = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let list = BatOption.default [] (CreateArgs.of_json_safe json) in
    
    let! () = ohm $ O.decay begin MMembership.Mass.create
	~from:(access # actor) (access # iid) asid list [ `Accept true ; `Default true ] 
    end in 
    
    let delay = if List.length list < 3 then 3000 else 6000 in
    
    return $ Action.javascript (Js.redirect ~delay ~url:back ()) res
      
  end in
  
  render $ Asset_Invite_ByEmail.render (object
    method url = OhmBox.reaction_json post () 
  end)   

(* Root box -------------------------------------------------------------------------------------- *)

let box kind url back access asid wrapper = 

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
    | `ByName  -> by_name  kind back access asid render
    | `ByGroup -> by_group kind back access asid render
    | `ByEmail -> by_email      back access asid render
  
