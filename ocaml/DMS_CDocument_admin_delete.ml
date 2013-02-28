(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common
open DMS_CDocument_admin_common

let () = define Url.Doc.def_delete begin fun parents rid doc access -> 
  
  let! submit = O.Box.react Fmt.Unit.fmt begin fun _ _ _ res -> 

    let respond = 
      let url = Action.url Url.see (access # instance # key) [ IRepository.to_string rid ] in
      return $ Action.javascript (Js.redirect url ()) res
    in

    (* Save the changes to the database. 
       Failure is silent. *)

    let! repo = ohm_req_or respond (MRepository.get ~actor:(access # actor) rid) in
    let! rid  = ohm_req_or respond (MRepository.Can.remove repo) in
    
    let! () = ohm (MDocument.Set.unshare rid doc (access # actor)) in

    respond

  end in   
  
  O.Box.fill begin 

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # delete # title
      method body = Asset_DMS_DeleteDoc.render (object
	method cancel = parents # admin # url
	method del = JsCode.Endpoint.to_json 
	  (OhmBox.reaction_endpoint submit ())
      end)
    end)

  end

end
