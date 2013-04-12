(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {      
      plugin  : IMail.Plugin.t ;
      data    : Json.t ;
      time    : Date.t ;
      zapped  : Date.t option ; 
      clicked : Date.t option ;
      opened  : Date.t option ;
      sent    : Date.t option ;
      solved  : [ `Solved "y" of Date.t | `NotSolved "n" of IMail.Solve.t ] option ; 
      iid     : IInstance.t option ; 
      uid     : IUser.t ;
      wid     : IMail.Wave.t ;
      blocked : bool ;
      accept  : bool option ;
      dead    : bool ; 
      item    : bool ; 
    }
  end
  include T
  include Fmt.Extend(T)
end 

include CouchDB.Convenience.Table(struct let db = O.db "mail" end)(IMail)(Data)

(* Clean updates ensure that small "pings" do not rewrite the entire document
   to the database if they don't actually change anything. *)
let clean_update mid f = 
  Tbl.transact mid (function 
  | None -> return ((), `keep)
  | Some m -> let m' = f m in 
	      if m = m' then return ((),`keep) else return ((),`put m') )

(* Rot means a "rotten" notification has been found (no "full" could be
   extracted from it), and it therefore has to be destroyed from the 
   database. *)
let rot mid = 
  clean_update mid Data.(fun m -> { m with dead = true })

(* Zap means that a given notification has been marked as seen. *)
let zap mid = 
  let! now = ohmctx (#time) in
  let  date = Date.of_timestamp now in
  clean_update mid Data.(fun m -> 
    if m.clicked = None then { m with zapped = Some (BatOption.default date m.zapped) }
    else m 
  ) 

let clicked mid = 
  let! now  = ohmctx (#time) in
  let  date = Date.of_timestamp now in
  clean_update mid Data.(fun m -> { m with clicked = Some (BatOption.default date m.clicked) })

let opened mid = 
  let! now = ohmctx (#time) in
  let  date = Date.of_timestamp now in
  clean_update mid Data.(fun m -> { m with opened = Some (BatOption.default date m.opened) })

let solved mid = 
  let! now = ohmctx (#time) in
  let  date = Date.of_timestamp now in 
  clean_update mid Data.(fun m -> { m with solved = match m.solved with 
    | Some (`NotSolved _) -> Some (`Solved date) 
    | other -> other 
  })

let blocked mid = 
  let! now = ohmctx (#time) in 
  clean_update mid Data.(fun m -> { m with sent = None ; blocked = true })
