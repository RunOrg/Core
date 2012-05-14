(* © 2012 RunOrg *)
  
open Ohm
open BatPervasives
open Ohm.Universal

module AnswerFmt = Fmt.Make(struct
  type json t = <
    id : IVote.t ;
    answers : int list
  >
end)

let reaction ~ctx = 
  O.Box.reaction "vote" begin fun _ bctx _ response -> 

    let respond ok = return $ O.Action.json [ "ok", Json_type.Bool ok] response in

    let! post = req_or (respond false) (AnswerFmt.of_json_safe (bctx # json)) in
    let! vote = ohm_req_or (respond false) (MVote.try_get ctx (post # id)) in
    let! vote = ohm_req_or (respond false) (MVote.Can.vote vote) in
    let! self = ohm $ ctx # self in
    let! ok   = ohm $ MVote.Mine.set vote self (post # answers) in
    respond ok

  end 

