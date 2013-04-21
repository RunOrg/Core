(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

let () = MDigest.Send.define begin fun uid u t info ->
  return None
end
