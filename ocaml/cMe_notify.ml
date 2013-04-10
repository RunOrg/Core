(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Settings = CMe_notify_settings

let  count = 10

let () = define UrlMe.Notify.def_home begin fun owid cuid ->   
  
  (* For this page only, act as if confirmed, because notifications
     might have to access data from instances. *)

  let cuid = ICurrentUser.Assert.is_old cuid in 

  (* Rendering a single item *)

  let render_item item = (object
    method body = 
      item # item owid
    method seen = 
      (item # info # clicked <> None 
       || item # info # zapped <> None) 
    && (match item # info # solved with Some (`NotSolved _) -> false | _ -> true) 
  end) in

  (* Rendering a list *)

  let render_list more start = 

    let! list, next = ohm $ O.decay (MMail.All.mine ~count ?start cuid) in
    let  list = List.map (fun item -> item # info # iid, item) list in
    
    let  by_iid = Ohm.ListAssoc.group_seq list in 
    
    let! list = ohm $ O.decay (Run.list_filter begin fun (iid,items) -> 
            
      let! instance = ohm_req_or (return None)  begin
	match iid with 
	  | None -> return $ Some (object
	    method name = "RunOrg"
	    method url  = "http://runorg.com/"
	    method pic  = Some "/public/img/logo-50x50.png"
	  end)
	  | Some iid -> 
	    let! instance = ohm_req_or (return None) $ MInstance.get iid in
	    let! pic = ohm $ CPicture.small_opt (instance # pic) in
	    return $ Some (object
	      method name = instance # name
	      method url  = Action.url UrlClient.website (instance # key) ()
	      method pic  = pic
	    end)					      
      end in 
      
      let items = List.map render_item items in
      
      return $ Some (object
	method instance = instance
	method items = items
      end)

    end by_iid) in

    Asset_Notify_List_Inner.render (object
      method list = list
      method more = match next with None -> None | Some time ->  
	Some (OhmBox.reaction_endpoint more time, Json.Null)
    end)

  in

  let! more = O.Box.react Date.fmt begin fun time _ self res -> 
    let! html = ohm $ O.decay (render_list self (Some time)) in
    return $ Action.json [ "more", Html.to_json html ] res
  end in

  let! zap = O.Box.react Fmt.Unit.fmt begin fun _ _ _ res ->
    let! () = ohm (O.decay (MMail.zap_unread cuid)) in
    return res
  end in
    
  O.Box.fill begin
    Asset_Notify_List.render (object
      method inner = O.decay (render_list more None)
      method zap = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint zap ())
      method options = Action.url UrlMe.Notify.settings owid () 
    end) 

  end 
end

let () = UrlMe.Notify.def_count begin fun req res -> 

  let respond count = 
    return $ Action.jsonp ?callback:(req # get "callback") (Json.Int count) res 
  in 

  let! cuid = req_or (respond 0) $ CSession.get req in 
  let! count = ohm $ MMail.All.unread cuid in 

  respond count

end 

