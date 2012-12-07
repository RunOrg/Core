(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core
module Can = MEntity_can
module Get = MEntity_get

type 'a t = 'a Can.t

let get = Can.data 
let id  = Can.id

let config t = (get t).E.config

let viewers entity =
  `Union (Can.get_view_access entity) 

let registered entity = 
  `Groups (`Validated,[entity.E.group])

let managers entity = 
  `Union (Can.get_manage_access entity) 

let make (entity : E.entity) = function
  | `Viewers    -> viewers entity
  | `Registered -> registered entity
  | `Managers   -> managers entity
    
(* Returning access rights for each satellite *)
 
let access t = 
  let c = config t in 
  let e = get t in
  function
    | `Wall what -> begin match MEntityConfig.wall e.E.template c with None -> `Nobody | Some w -> 
      match what with 
	| `Manage -> managers e
	| `Write  -> make e (w # post) 
	| `Read   -> make e (w # read)
    end
    | `Album what -> begin match MEntityConfig.album e.E.template c with None -> `Nobody | Some a -> 
      match what with 
	| `Manage -> managers e
	| `Write  -> make e (a # post) 
	| `Read   -> make e (a # read)
    end
    | `Folder what -> begin match MEntityConfig.folder e.E.template c with None -> `Nobody | Some f -> 
      match what with 
	| `Manage -> managers e
	| `Write  -> make e (f # post) 
	| `Read   -> make e (f # read)
    end
    | `Votes what -> begin match MEntityConfig.votes e.E.template c with None -> `Nobody | Some v -> 
      match what with 
	| `Manage -> managers e
	| `Vote   -> make e (v # vote) 
	| `Read   -> make e (v # read) 
    end
    | `Group what -> begin match MEntityConfig.group e.E.template c with None -> `Nobody | Some g -> 
      match what with
	| `Manage -> managers e
	| `Write  -> managers e
	| `Read   -> make e (g # read) 
    end

let has_votes t = 
  let c = config t in
  let e = get t in
  MEntityConfig.votes e.E.template c <> None
