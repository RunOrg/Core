(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.rename_instance

  module Format = Fmt.Make(struct
    type json t = <
      old_url "old" : string ;
      new_url "new" : string ;
    >
  end)

  let example = (object
    method old_url = "mauvais-nom.runorg.com"
    method new_url = "nom-correct.ffbad.fr"
  end)
    
  let action cuid json =

    let  old_domain = json # old_url in 
    let  old_okey, old_owid = ConfigWhite.slice_domain old_domain in
    let! old_key = req_or (fail "Domaine inconnu: '%s'" old_domain) old_okey in
    let  src = (old_key,old_owid) in

    let  new_domain = json # new_url in 
    let  new_okey, new_owid = ConfigWhite.slice_domain new_domain in
    let! new_key = req_or (fail "Domaine inconnu: '%s'" new_domain) new_okey in
    let  dest = (new_key,new_owid) in

    let! result = ohm $ MInstance.Backdoor.relocate ~src ~dest in

    match result with 
      | `OK -> ok "Déplacement %s -> %s effectué, redémarrez le serveur!" (json # old_url) (json # new_url) 
      | `NOT_FOUND -> fail "Association %s non trouvée" (json # old_url) 
      | `EXISTS -> fail "Association %s existe déjà" (json # new_url) 

end)
