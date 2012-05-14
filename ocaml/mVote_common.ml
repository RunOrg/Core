(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Vote = struct
  module Config   = MVote_data.Config
  module Owner    = MVote_owner
  module Question = MVote_data.Question
  module Float    = Fmt.Float
  module T = struct
    type json t = {
      creator   "a" : IAvatar.t ;
      owner     "o" : Owner.t ;
      question  "q" : Question.t ; 
      config    "c" : Config.t ;
      time      "t" : Float.t ;
     ?anonymous "n" : bool = false
    }
  end
  include T
  include Fmt.Extend(T)
end

type 'relation vote = {
  data  : Vote.t ;
  id    : 'relation IVote.id ;
  read  : bool O.run ;
  vote  : bool O.run ;
  admin : bool O.run
}

type 'relation t = 'relation vote

let make_from_context id data ctx = 
  let access = Run.memo begin
    let nil _ = `Nobody in
    match data.Vote.owner with 
      | `entity eid -> let! entity = ohm_req_or (return nil) $ MEntity.naked_get eid in 
		       return (fun what -> MEntity.Satellite.access entity (`Votes what))
  end in 
  let read  = let! f = ohm access in MAccess.test ctx [ f `Read ; f `Vote ; f `Manage ] in
  let admin = let! f = ohm access in MAccess.test ctx [                     f `Manage ] in
  let vote  = let! f = ohm access in MAccess.test ctx [           f `Vote             ] in
  { data ; id ; read ; vote ; admin }

let make_naked id data = 
  { data ; id ; read = return false ; vote = return false ; admin = return false }

let make_from id t =
  { id ; data = t.data ; read = t.read ; vote = t.vote ; admin = t.admin } 

module VoteDB = MModel.Register(struct let db = "vote" end)
module VoteTable = CouchDB.Table(VoteDB)(IVote)(Vote)

module VoteDesign = struct
  module Database = VoteDB
  let name = "vote"
end

module Ballot = struct
  module T = struct
    type json t = {
      who     "a" : IAvatar.t ;
      vote    "v" : IVote.t ;
      answers "b" : int list ;
      counted "c" : bool
    }
  end
  include T
  include Fmt.Extend(T)
end

module BallotDB = MModel.Register(struct let db = "vote-ballot" end)
module BallotTable = CouchDB.Table(BallotDB)(Id)(Ballot)

module BallotDesign = struct
  module Database = BallotDB
  let name = "ballot"
end

let ballot_key who vote = Id.of_string (IVote.to_string vote ^ "-" ^ IAvatar.to_string who)

let ballot_get who vote = 
  let key = ballot_key who vote in
  BallotTable.get key 

let ballot_update who vote f = 
  let key = ballot_key who vote in
  let default = Ballot.({ 
    who = IAvatar.decay who ;
    vote = IVote.decay vote ;
    answers = [] ;
    counted = true 
  }) in
  let update id = 
    let! ballot_opt = ohm $ BallotTable.get id in
    let  ballot     = BatOption.default default ballot_opt in
    let! ballot'    = ohm_req_or (return ((),`keep)) $ f ballot in
    if ballot = ballot' then return ((),`keep) else return ((),`put ballot')
  in
  BallotTable.transaction key update
      
