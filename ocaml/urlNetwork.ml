(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "network/search" A.none

let news, def_news = O.declare O.core "network/news" (A.o A.float)

let more, def_more = O.declare O.core "network/more" (A.rn IInstance.arg A.string) 

let unbound, def_unbound = O.declare O.core "network/stub" (A.r IInstance.arg)
