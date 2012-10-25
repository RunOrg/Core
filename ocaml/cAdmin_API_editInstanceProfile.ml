(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.edit_instance_profile

  module Format = Fmt.Make(struct
    type json t = <
      name : string ;
      url  : string ;
     ?address : string option ;
     ?tags : string list = [] ;
      owners : string list
    >
  end)

  let example = (object
    method name = "Football Club Paris XXe"
    method url  = "fc75020.runorg.com"
    method address = Some "22 rue Planchat, 75020 Paris"
    method tags = [ "football" ; "sport" ; "club" ; "paris" ]
    method owners = [ "vnicollet@runorg.com" ; "mfoughali@runorg.com" ]
  end)
    
  let action cuid json =

    let  domain = json # url in 
    let  okey, owid = ConfigWhite.slice_domain domain in
    let! key = req_or (fail "Domaine inconnu: '%s'" domain) okey in

    ok "Instance profile %s (%s) edited" (Util.uniq ()) (json # url) 

end)
