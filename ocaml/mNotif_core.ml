(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
      plugin : IMail.Plugin.t ;
      data   : Json.t ;
      time   : float ;
      read   : float option ;
      sent   : float option ;
      solved : float option ;
      nmc    : int ;
      nsc    : int ;
      nzc    : int ; 
      iid    : IInstance.t option ; 
      uid    : IUser.t ;
      mid    : IMailing.t ;
      solve  : IMail.Solve.t option ;
      dead   : bool ; 
    }
  end
  include T
  include Fmt.Extend(T)
end 

include CouchDB.Convenience.Table(struct let db = O.db "notif" end)(IMail)(Data)

(* Rot means a "rotten" notification has been found (no "full" could be
   extracted from it), and it therefore has to be destroyed from the 
   database. *)
let rot mid = 
  Tbl.update mid Data.(fun m -> { m with dead = true })

(* Zap means that a given notification has been marked as seen. *)
let zap mid = 
  let! now = ohmctx (#time) in
  Tbl.update mid Data.(fun m -> { m with read = Some (BatOption.default now m.read) ; nzc = m.nzc + 1 }) 

let seen_from_mail mid = 
  let! now = ohmctx (#time) in
  Tbl.update mid Data.(fun m -> { m with read = Some (BatOption.default now m.read) ; nmc = m.nmc + 1 }) 

let seen_from_site mid = 
  let! now = ohmctx (#time) in
  Tbl.update mid Data.(fun m -> { m with read = Some (BatOption.default now m.read) ; nsc = m.nsc + 1 }) 
