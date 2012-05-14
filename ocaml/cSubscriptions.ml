(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Workflow subscription process ------------------------------------------------------------ *)

module Workflow = struct

  module UrlSubs = UrlSubscription

  let () = CClient.register UrlSubs.start begin fun i18n (iid, instance) request response ->
    
    let! user = ohm begin
      match 
	request # cookie CSession.name
	|> BatOption.bind CSession.get_login_cookie
      with 
	| None -> return None 
	| Some cuid ->
	  MUser.get (IUser.Deduce.unsafe_can_view cuid) |> Run.map begin function
	    | None      -> None
	    | Some user -> Some (user, cuid) 
	  end
    end in
    
    let title = return (View.esc (instance # name)) in
    let body = 

      let! profile = ohm $ MInstance.Profile.get iid in
      let  profile = BatOption.default (MInstance.Profile.empty iid) profile in 

      let! picture = ohm (CPicture.large instance # pic) in
      let! list    = ohm (MEntity.All.get_public_granting iid) in
	
      let list = List.map begin fun entity -> 
	(object
	  method url     = (UrlSubs.form ()) # build instance (MEntity.Get.id entity)
	  method name    = CName.of_entity entity
	  method summary = MEntity.Get.summary entity
	 end)	    
      end list in
      
      let data = object
	method list    = list
	method picture = picture
	method desc    = BatOption.default "" profile # desc
	method name    = instance # name 
      end in
      
      if list = [] then 
	return 
	  (VSubscription.Workflow.NoChoices.render
	     (data :> VSubscription.Workflow.NoChoices.t)
	     (i18n))
      else
	return (VSubscription.Workflow.Choose.render data i18n)
    in 
    
    let! white = ohm $ Run.opt_bind MWhite.get (instance # white) in

    let navbar    = 
      
      let runorg_name = 
	match white with 
	  | None -> "RUN<strong>ORG</strong>"
	  | Some white -> MWhite.name white
      in

      match user with
 
	| Some (user, cuid) -> 

	  let! news_count = ohm (MNotification.count cuid) in 	  
	  let! message_count = ohm (MMessage.total_count begin
	    IUser.Deduce.unsafe_is_anyone cuid
	    |> IUser.Assert.is_self
	  end) in 
	  
	  let user_name = user # fullname in 
     
	  CCore.navbar runorg_name cuid user_name (Some iid) news_count message_count i18n 

	| None ->

	  return (VCore.navbar_empty runorg_name ~title:(`text (instance # name)) ~i18n)
    in

    let theme = match BatOption.map MWhite.theme white with 
      | None   -> BatOption.map (fun theme -> theme, `RunOrg) instance # theme 
      | Some t -> Some (t, `White) 
    in
        
    CCore.render ?theme ~css:CCore.css_client ~navbar ~title ~body response

  end
    
  let () = CClient.register UrlSubs.finish begin fun i18n (iid, instance) request response ->

    let user_fail = CCore.redirect_fail (UrlLogin.index # build) response in    

    let! cuid = req_or user_fail
      (request # cookie CSession.name |> BatOption.bind CSession.get_login_cookie) in
    
    let! user_opt = ohm (MUser.get (IUser.Deduce.unsafe_can_view cuid)) in
    let! user = req_or user_fail user_opt in

    let! isin = ohm (MAvatar.identify iid cuid) in
    
    let title = return (View.esc (instance # name)) in
    let body = 
      let! picture = ohm (CPicture.large (instance # pic)) in

      return (	
	begin match IIsIn.Deduce.is_token isin with 
	  | None -> VSubscription.Workflow.finish_later
	  | Some _ -> VSubscription.Workflow.finish_now 
	end
	  ~url:(UrlR.r # build instance)
	  ~picture
	  ~name:(instance # name)
	  ~i18n
      )
    in 

    let! white = ohm $ Run.opt_bind MWhite.get (instance # white) in

    let navbar    = 

      let! news_count = ohm (MNotification.count cuid) in
      let! message_count = ohm (MMessage.total_count begin
	IUser.Deduce.unsafe_is_anyone cuid
	|> IUser.Assert.is_self
      end) in

      let runorg_name = 
	match white with 
	  | None -> "RUN<strong>ORG</strong>"
	  | Some white -> MWhite.name white
      in
     
      let user_name = user # fullname in 
      CCore.navbar runorg_name cuid user_name (Some iid) news_count message_count i18n 	
    in

    let theme = match BatOption.map MWhite.theme white with 
      | None   -> BatOption.map (fun theme -> theme, `RunOrg) instance # theme 
      | Some t -> Some (t, `White) 
    in
                
    CCore.render ?theme ~css:CCore.css_client ~navbar ~title ~body response

  end

  let () = CClient.register (UrlSubs.form ()) begin fun i18n (iid, instance) request response ->
    let eid      = BatOption.map IEntity.of_string (request # args 0) in
    let segments = O.Box.Seg.(UrlSegs.(root ++ root_pages ++ entity_id ++ entity_tabs)) in
    let data     = ((((),`Entity),eid),`Info) in
    return $ Action.redirect (UrlR.build instance segments data) response
  end

end

