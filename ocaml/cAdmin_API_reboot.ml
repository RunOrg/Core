(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.reboot

  module Format = Fmt.Unit

  let example = ()
    
  let action cuid json =
    let! () = ohm $ O.Reset.run () in
    ok "Admin status granted"

end)
