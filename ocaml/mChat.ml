(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Arr         = MChat_arr
module Line        = MChat_line
module Participant = MChat_participant
module Room        = MChat_room
module Feed        = MChat_feed

let post crid payload self = 

  (* You can only post payloads that have you as an author *)
  let by_self = IAvatar.decay self = Line.author payload in
  let! () = true_or (return ()) by_self in

  (* Save to database before publishing, so archives are complete *)
  let! line = ohm $ Feed.post payload crid in
  let! ()   = ohm $ Room.send crid line in  

  return () 

let url crid self = 
  let! url = ohm_req_or (return None) $ Room.url crid self in 
  let! ()  = ohm $ Participant.participate (IAvatar.decay self) (IChat.Room.decay crid) in
  return $ Some url 

(* TODO *)
let delete_now crid = 
  return ()
