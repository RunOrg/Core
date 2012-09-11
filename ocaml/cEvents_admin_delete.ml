(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_delete begin fun parents entity access -> 
  
  let! submit = O.Box.react Fmt.Unit.fmt begin fun _ _ _ res -> 

    (* Save the changes to the database *)

    let! () = ohm $ O.decay (MEntity.delete (access # self) entity) in

    (* Redirect to entity home *)

    let url = Action.url UrlClient.Events.home (access # instance # key) [] in

    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill begin 

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # delete # title
      method body = Asset_Event_Delete.render (object
	method cancel = parents # admin # url
	method del = JsCode.Endpoint.to_json 
	  (OhmBox.reaction_endpoint submit ())
      end)
    end)

  end

end
