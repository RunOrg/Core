(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common 

let () = CClient.define Url.def_upload begin fun access ->
  
  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid   = O.Box.parse IRepository.seg in
  let! repo  = ohm_req_or e404 $ MRepository.view ~actor rid in
  let! uprid = ohm_req_or e404 $ MRepository.Can.upload repo in 

  O.Box.fill begin 
    return (Html.str "")
  end 

end 
