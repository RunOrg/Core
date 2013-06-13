(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let vote,   def_vote   = O.declare O.client "minipoll/vote" (A.rr IPoll.arg A.string) 
let voters, def_voters = O.declare O.client "minipoll/voters" (A.rr IPoll.arg A.string)
