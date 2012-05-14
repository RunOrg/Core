(* © 2012 RunOrg *)
  
open Ohm
open BatPervasives
open Ohm.Universal

let reaction ~ctx = 
  O.Box.reaction "close" begin fun _ bctx _ response -> 

    let ok ok = O.Action.json ["ok", Json_type.Bool ok] response in
    let fail = return $ ok false in

    let! id   = req_or     fail (IVote.of_json_safe (bctx # json)) in
    let! vote = ohm_req_or fail (MVote.try_get ctx id) in
    let! vote = ohm_req_or fail (MVote.Can.admin vote) in
    let! ()   = ohm $ MVote.Config.close vote in

    return $ O.Action.javascript (JsBase.boxRefresh 0.0) (ok true)

  end 

