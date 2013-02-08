(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.set_plugins

  module Format = Fmt.Make(struct
    type json t = <
      name : string ;
      plugins : IPlugin.t list ; 
    >
  end)

  let example = (object
    method name = "nom.runorg.com"
    method plugins = [ `DMS ]
  end)
    
  let action cuid json =

    let  name = json # name in 
    let  okey, owid = ConfigWhite.slice_domain name in
    let! key = req_or (fail "Domaine inconnu: '%s'" name) okey in
    let  src = (key,owid) in

    let! result = ohm $ MInstance.Backdoor.set_plugins (json # plugins) src in

    match result with 
      | `OK -> ok "Modification des plugins de %s effectuée" (json # name) 
      | `NOT_FOUND -> fail "Association %s non trouvée" (json # name) 

end)
