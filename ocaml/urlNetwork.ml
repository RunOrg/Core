(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "network/all" A.none
let tag,  def_tag  = O.declare O.core "network/tag" (A.r A.string)

let news, def_news = O.declare O.core "network/news" (A.o A.float)

let more, def_more = O.declare O.core "network/more" (A.ro IInstance.arg  A.string) 
