(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.set_disk

  module Format = Fmt.Make(struct
    type json t = <
      name : string ;
      gigaoctets : float ; 
    >
  end)

  let example = (object
    method name = "nom.runorg.com"
    method gigaoctets = 0.05
  end)
    
  let action cuid json =

    let  name = json # name in 
    let  okey, owid = ConfigWhite.slice_domain name in
    let! key = req_or (fail "Domaine inconnu: '%s'" name) okey in
    let  src = (key,owid) in

    let! result = ohm $ MInstance.Backdoor.set_disk (json # gigaoctets) src in

    match result with 
      | `OK -> ok "Modification de l'espace disque de %s effectuée" (json # name) 
      | `NOT_FOUND -> fail "Espace %s non trouvé" (json # name) 

end)
