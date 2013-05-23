(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common
open DMS_CRepository_admin_common

let () = define Url.Repo.def_delete begin fun parents repo access -> 

  let respond body = 
    O.Box.fill (O.decay begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # delete # title
	method body = body
      end)
    end)
  in  

  (* Only accept deletion if there are no documents in the repository. *)

  let failure = respond (Asset_DMS_DeleteRepoForbidden.render ()) in
  let! count = ohm (MDocument.All.count_in_repository (MRepository.Get.id repo)) in

  let! () = true_or failure (count = 0) in

  let! submit = O.Box.react Fmt.Unit.fmt begin fun _ _ _ res -> 

    let respond = 
      let url = Action.url Url.home (access # instance # key) [] in
      return $ Action.javascript (Js.redirect url ()) res
    in

    (* Save the changes to the database. *)
    
    let! () = ohm (MRepository.delete repo (access # actor)) in

    respond

  end in   
  
  respond (Asset_DMS_DeleteRepo.render (object
    method cancel = parents # admin # url
    method del = JsCode.Endpoint.to_json 
      (OhmBox.reaction_endpoint submit ())
  end))

end
