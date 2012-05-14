(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Search  = CMe_network_search
module Request = CMe_network_request
module Profile = CMe_network_profile
module Follow  = CMe_network_follow

let render_list key_iid_list url_builder = 

  let render_instance (key,iid) = 
    
    let! instance = ohm_req_or (return None) (MInstance.get iid) in		
    let! pic = ohm (CPicture.small (instance # pic)) in
    
    return (Some (object
      method name = instance # name 
      method pic  = pic
      method url  = url_builder key instance 
    end))
      
  in

  Run.list_filter render_instance key_iid_list  
    
let requests ~i18n ~user = 

  let list_requests = 
    O.Box.leaf begin fun input (prefix,_) ->    
      
      let! list = ohm $ MRelatedInstance.get_all_mine user in
      let key_iid_list = List.map (fun (rid,data) -> (rid,data.MRelatedInstance.Data.related_to)) list in 
      
      let url_builder rid _ =
	UrlMe.build input # segments (prefix,Some (IRelatedInstance.decay rid))
      in
      
      let! instances = ohm $ render_list key_iid_list url_builder in 
      
      return (VMe.Network.RequestList.render (object
	method list   = instances
      end) i18n)
	
    end   
  in

  O.Box.decide begin fun _ (_,rid_opt) ->

    match rid_opt with 
      | None     -> return list_requests
      | Some rid -> return $ Request.box rid i18n user

  end
  |> O.Box.parse UrlSegs.related_instance_id 
    

let isin status ~i18n ~user = 
  O.Box.leaf begin fun input _ ->

    let! sta_iid_list = ohm begin 
      MAvatar.user_instances ~status (user |> IUser.Deduce.is_self |> IUser.Deduce.self_can_view_inst)
    end in 
      
    let! instances = ohm $ render_list sta_iid_list (fun sta instance -> UrlR.home # build instance) in
    
    let create_url = UrlFunnel.start # build in
    
    return (VMe.Network.List.render (object
      method create = if status = `Admin then Some create_url else None
      method list   = instances
    end) i18n)
	
  end    

let box ~i18n ~user = 
  
  let tabs ~i18n = 
    CTabs.box 
      ~list:[ CTabs.fixed `Search   (`label "me.network.tab.search")   
		(lazy (Search.box i18n user)) ;

	      CTabs.hidden begin function 
		| `Profile -> return $ Some
		  (`label "me.network.tab.profile", Profile.box i18n user) 
		| `Follow -> return $ Some
		  (`label "me.network.tab.follow", Follow.box i18n user) 
		| _ -> return None
	      end ;

	      CTabs.fixed `Admin    (`label "me.network.tab.admin")   
		(lazy (isin `Admin   i18n user)) ;
	      CTabs.fixed `Member   (`label "me.network.tab.member") 
		(lazy (isin `Token   i18n user)) ;
	      CTabs.fixed `Contact  (`label "me.network.tab.contact") 
		(lazy (isin `Contact i18n user)) ;
	      CTabs.fixed `Requests (`label "me.network.tab.requests")
		(lazy (requests      i18n user)) ;
	    ]
      ~url:(UrlMe.build)
      ~default:`Admin
      ~seg:CSegs.me_network_tabs
      ~i18n
  in
  let content = "content" in
  O.Box.node 
    (fun input _ -> 
      return [content,tabs ~i18n], 
      return (VMe.Network.full ~box:(input # name,content) ~i18n))
