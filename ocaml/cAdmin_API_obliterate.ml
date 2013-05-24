(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.obliterate

  module Format = Fmt.Make(struct
    type json t = <
      email : string ;
    >
  end)

  let example = (object
    method email = "to-be-deleted@runorg.com"
  end)
    
  let action cuid json =

    let! uid = ohm_req_or (fail "Utilisateur %s non trouvé" (json # email)) 
      (MUser.by_email (json # email)) in
    
    let uid = IUser.Assert.unsubscribe uid in 

    let! _ = ohm $ MUser.obliterate uid in 

    ok "Utilisateur %s (%s) définitivement supprimé !" (json # email) (IUser.to_string uid) 

end)
