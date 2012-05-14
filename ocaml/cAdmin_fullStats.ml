(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(*
let () = CAdmin_common.register UrlAdmin.full_stats begin fun i18n user request response ->
  let idopt = BatOption.map Id.of_string (request # post "start") in
  log "Start: %s" (BatOption.default "null" (BatOption.map Id.str idopt)) ;
  let! (dump,idopt) = ohm (MProfileAudit.dump idopt) in
  return (Action.json [
    "data", dump ;
    "start", Json_type.Build.optional Id.to_json idopt 
  ] response)
end
*)
