(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core

module Access = MEntity_access

type 'a t = 'a MEntity_can.t

let get = MEntity_can.data 
let id  = MEntity_can.id

let config t = (get t).E.config
    
(* Returning access rights for each satellite *)

let access t = 
  let c = config t in 
  let e = get t in
  function
    | `Wall what -> begin match MEntityConfig.wall e.E.template c with None -> `Nobody | Some w -> 
      match what with 
	| `Manage -> Access.managers t
	| `Write  -> Access.make t (w # post) 
	| `Read   -> Access.make t (w # read)
    end
    | `Album what -> begin match MEntityConfig.album e.E.template c with None -> `Nobody | Some a -> 
      match what with 
	| `Manage -> Access.managers t
	| `Write  -> Access.make t (a # post) 
	| `Read   -> Access.make t (a # read)
    end
    | `Folder what -> begin match MEntityConfig.folder e.E.template c with None -> `Nobody | Some f -> 
      match what with 
	| `Manage -> Access.managers t
	| `Write  -> Access.make t (f # post) 
	| `Read   -> Access.make t (f # read)
    end
    | `Votes what -> begin match MEntityConfig.votes e.E.template c with None -> `Nobody | Some v -> 
      match what with 
	| `Manage -> Access.managers t
	| `Vote   -> Access.make t (v # vote) 
	| `Read   -> Access.make t (v # read) 
    end
    | `Group what -> begin match MEntityConfig.group e.E.template c with None -> `Nobody | Some g -> 
      match what with 
	| `Manage -> Access.managers t
	| `Write  -> Access.managers t
	| `Read   -> Access.make t (g # read) 
    end

let has_votes t = 
  let c = config t in
  let e = get t in
  MEntityConfig.votes e.E.template c <> None
