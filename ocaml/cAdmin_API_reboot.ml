(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.reboot

  module Format = Fmt.Unit

  let example = ()
    
  let action cuid json =
    let () = O.Reset.send () in
    ok "Admin status granted"

end)
