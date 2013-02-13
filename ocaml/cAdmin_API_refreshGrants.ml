(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.refresh_grants

  module Format = Fmt.Unit

  let example = ()
    
  let action cuid json =
    let! () = ohm $ MAvatar.Backdoor.refresh_grants () in
    ok "Grant refresh started"

end)
