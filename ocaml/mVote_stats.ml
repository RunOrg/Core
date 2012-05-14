(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MVote_common

type t = <
  count   : int ;
  votes   : (Ohm.I18n.text * int) list 
> ;;

module VoteAnswer = Fmt.Make(struct
  type json t = IVote.t * int option
end)

module CountView = CouchDB.ReduceView(struct
  module Key    = VoteAnswer
  module Value  = Fmt.Int
  module Design = BallotDesign 
  let name = "count"
  let map  = "if (doc.c) { 
                emit([doc.v,null],1);
                for (var i = 0; i < doc.b.length; ++i)
                  emit([doc.v,doc.b[i]],1);
              }"
  let reduce = "return sum(values)"
  let group = true
  let level = None
end)

let none = object
  method count  = 0
  method votes  = []
end

let get_short vote = 

  let  vid  = IVote.decay vote.id in 
  let! vote = ohm_req_or (return none) $ VoteTable.get vid in 
  let! list = ohm $ CountView.reduce_query ~startkey:(vid,Some 0) ~endkey:(vid,None) () in

  let count   = try List.assoc (vid,None) list with Not_found -> 0 in
  let answers = BatList.mapi (fun i answer -> answer, 
    (try List.assoc (vid,Some i) list with Not_found -> 0)) (vote.Vote.question # answers) in

  return (object
    method count = count
    method votes = answers 
  end)

module VoterView = CouchDB.DocView(struct
  module Key    = IVote
  module Value  = Fmt.Unit
  module Doc    = Ballot
  module Design = BallotDesign 
  let name = "voters"
  let map  = "if (doc.c) emit(doc.v)"
end)

let get_long vote = 

  let anon  = vote.data.Vote.anonymous in
  let  vid  = IVote.decay vote.id in 
  let! list = ohm $ VoterView.doc vid in

  let count = List.length list in 

  if count < 5 && anon then return [] else
    return $ List.map (fun item -> 
      (item # doc).Ballot.who, if anon then [] else (item # doc).Ballot.answers
    ) list 

