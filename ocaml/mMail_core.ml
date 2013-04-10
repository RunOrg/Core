(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {      
      plugin  "p"  : IMail.Plugin.t ;
      data    "j"  : Json.t ;
      time    "t"  : Date.t ;
      zapped  "z"  : Date.t option ; 
      clicked "c"  : Date.t option ;
      opened  "o"  : Date.t option ;
      sent    "s"  : Date.t option ;
      solved  "so" : [ `Solved "y" of Date.t | `NotSolved "n" of IMail.Solve.t ] option ; 
      iid     "i"  : IInstance.t option ; 
      uid     "u"  : IUser.t ;
      wid     "w"  : IMail.Wave.t ;
      blocked "b"  : bool ;
      accept  "a"  : bool option ;
      dead    "d"  : bool ; 
      item    "l"  : bool ; 
    }
  end
  include T
  include Fmt.Extend(T)
end 

include CouchDB.Convenience.Table(struct let db = O.db "mail" end)(IMail)(Data)

(* Rot means a "rotten" notification has been found (no "full" could be
   extracted from it), and it therefore has to be destroyed from the 
   database. *)
let rot mid = 
  Tbl.update mid Data.(fun m -> { m with dead = true })

(* Zap means that a given notification has been marked as seen. *)
let zap mid = 
  let! now = ohmctx (#time) in
  let  date = Date.of_timestamp now in
  Tbl.update mid Data.(fun m -> 
    if m.clicked = None then { m with zapped = Some (BatOption.default date m.zapped) }
    else m 
  ) 

let clicked mid = 
  let! now  = ohmctx (#time) in
  let  date = Date.of_timestamp now in
  Tbl.update mid Data.(fun m -> { m with clicked = Some (BatOption.default date m.clicked) })

let opened mid = 
  let! now = ohmctx (#time) in
  let  date = Date.of_timestamp now in
  Tbl.update mid Data.(fun m -> { m with opened = Some (BatOption.default date m.opened) })

let solved mid = 
  let! now = ohmctx (#time) in
  let  date = Date.of_timestamp now in 
  Tbl.update mid Data.(fun m -> { m with solved = match m.solved with 
    | Some (`NotSolved _) -> Some (`Solved date) 
    | other -> other 
  })
