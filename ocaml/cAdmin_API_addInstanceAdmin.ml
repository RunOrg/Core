(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.add_instance_admin

  module Format = Fmt.Make(struct
    type json t = < url : string ; email : string >
  end)

  let example = (object
    method url   = "nous.runorg.com"
    method email = "vnicollet@runorg.com"
  end)
    
  let action cuid json =
    let  email = json # email in
    let! uid = ohm_req_or (fail "Utilisateur inconnu: '%s'" email) $ MUser.by_email email in 
    return (Bad "Not implemented")

end)
