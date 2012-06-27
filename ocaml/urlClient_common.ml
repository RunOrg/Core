(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root,    def_root      = O.declare O.client "intranet" A.none

let declare ?p url = 
  let endpoint, define = O.declare O.client ("intranet/ajax/" ^ url) (A.n A.string) in
  let endpoint = Action.rewrite endpoint "intranet/ajax" "intranet/#" in
  let root key = Action.url root key () in
  let prefix = "/" ^ url in
  let parents = match p with 
    | None -> [] 
    | Some (_,prefix,parents,_) -> parents @ [prefix] 
  in
  endpoint, (root,prefix,parents,define)

let root url = declare url 
let child p url = declare ~p url 

type definition = (string -> string) * string * string list * 
    (   (   (string, string list) Ohm.Action.request
          -> Ohm.Action.response 
          -> (O.ctx, Ohm.Action.response) Ohm.Run.t)
     -> unit)
