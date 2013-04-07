(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
      plugin : INotif.Plugin.t ;
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
      solve  : INotif.Solve.t option ;
      dead   : bool ; 
    }
  end
  include T
  include Fmt.Extend(T)
end 

include CouchDB.Convenience.Table(struct let db = O.db "notif" end)(INotif)(Data)

(* Rot means a "rotten" notification has been found (no "full" could be
   extracted from it), and it therefore has to be destroyed from the 
   database. *)
let rot nid = 
  Tbl.update nid Data.(fun n -> { n with dead = true })

(* Zap means that a given notification has been marked as seen. *)
let zap nid = 
  let! now = ohmctx (#time) in
  Tbl.update nid Data.(fun n -> { n with read = Some (BatOption.default now n.read) ; nzc = n.nzc + 1 }) 

let seen_from_mail nid = 
  let! now = ohmctx (#time) in
  Tbl.update nid Data.(fun n -> { n with read = Some (BatOption.default now n.read) ; nmc = n.nmc + 1 }) 

let seen_from_site nid = 
  let! now = ohmctx (#time) in
  Tbl.update nid Data.(fun n -> { n with read = Some (BatOption.default now n.read) ; nsc = n.nsc + 1 }) 
