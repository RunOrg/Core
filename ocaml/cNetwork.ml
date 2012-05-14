(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module New    = CNetwork_new
module Edit   = CNetwork_edit	
module Public = CNetwork_public

let list_box ~ctx ~token_ctx ~admin_ctx = 
  O.Box.leaf begin fun bctx (prefix,_) ->

    let iid = IInstance.decay (IIsIn.instance (ctx # myself)) in

    let add_action =
      match token_ctx with
	| Some _ -> let url = UrlR.build (ctx # instance) (bctx # segments) (prefix,`New) in  
		    VCore.GreenLinkButton.render (url , `label "add")
	| None -> (fun _ -> Ohm.View.str "&nbsp;") 
    in

    let search_action =
      match token_ctx with
	| Some _ -> let url = UrlMe.build
		      O.Box.Seg.(root ++ UrlSegs.me_pages ++ UrlSegs.me_network_tabs `Search)
		      (((),`Network),`Search)
		    in  
		    VCore.LinkButton.render (url , `label "search")
	| None -> (fun _ -> Ohm.View.str "&nbsp;") 
    in

    let! following = ohm MRelatedInstance.(begin match CClient.is_token (ctx # myself) with 
      | None      -> get_all_public (IInstance.decay (IIsIn.instance (ctx # myself))) 
      | Some isin -> get_all (IIsIn.instance isin)	
    end) in

    let! following_detailed = ohm $ Run.list_map begin fun (rid,item) -> 

      let! description = ohm $ MRelatedInstance.describe item in 
      let! pic = ohm $ ctx # picture_small (description # picture) in

      let url = match description # url with
	| `None      -> None
	| `Site    s -> Some s
	| `Key     k -> Some (UrlR.index # key_build k)
	| `Profile i -> let segs = 
			  O.Box.Seg.(UrlSegs.(root ++ me_pages ++ me_network_tabs `Profile
					       ++ instance_id))
			in
			let url = UrlMe.build segs ((((),`Network),`Profile),Some i) in
			Some url 
      and edit = UrlR.build (ctx # instance) (bctx # segments) 
	(prefix,`Item (IRelatedInstance.decay rid))
      and name = BatOption.default (`label "network.deleted") 
	(BatOption.map (fun text -> `text text) description # name)
      and access = match description # access with 
	| `Public  -> Some (`Page `Public) 
	| `Private -> Some (`Page `Normal) 
      in 

      return (object
	method edit = if admin_ctx <> None then Some edit else None
	method url = url
	method name = name
	method picture = pic
	method access = access
      end)
    end following in 

    let! followers = ohm $ MRelatedInstance.get_listeners iid in 
    
    let! followers_detailed = ohm $ Run.list_map begin fun iid ->
      let! instance = ohm_req_or (return None) $ MInstance.get iid in
      let! pic = ohm $ ctx # picture_small (instance # pic) in
      let  url = UrlR.index # key_build (instance # key) in
      return $ Some (object
	method url = url
	method picture = pic
	method name = instance # name
      end)
    end followers in 

    let followers_detailed = BatList.filter_map identity followers_detailed in 

    let! stats = ohm $ MRelatedInstance.count iid in

    let data = object 
      method followers = followers_detailed
      method name      = ctx # instance # name
      method following_count = stats # following
      method followers_count = stats # followers
      method following = following_detailed
      method access = Some (`Page `Public)
      method add = add_action
      method search = search_action
    end in 

    return $ VNetwork.Index.render data (ctx # i18n) 
  end
    
let box ~ctx = 

  let admin_ctx = 
    match CClient.is_admin (ctx # myself) with 
      | None      -> None
      | Some isin -> Some (CContext.evolve_full isin ctx)
  in

  let token_ctx = 
    match CClient.is_token (ctx # myself) with 
      | None      -> None
      | Some isin -> Some (CContext.evolve_full isin ctx)
  in

  O.Box.decide begin fun _ (_,tab) ->
    let list =  return $ list_box ~ctx ~admin_ctx ~token_ctx in 
    match tab with 
      | `List   -> list
      | `New    -> let! ctx  = req_or list token_ctx in 
		   return $ New.box ~ctx 
      | `Item i -> let! item = ohm $ MRelatedInstance.get ctx i in 
		   match item with 
		     | `Admin (rid,data) -> return $ Edit.box ~ctx rid data
		     | `None | `View _   -> list 
  end
  |> O.Box.parse UrlSegs.network_tabs 
