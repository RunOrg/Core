(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core

(* Accessing the entity -------------------------------------------------------------------- *)

let manage_access entity = 
  if entity.E.deleted = None then [ `Admin ; entity.E.admin ] else []

let has_manage_access entity context = 
  MAccess.test context (manage_access entity)

let view_access entity = 
  if entity.E.deleted = None then 
    let admin = [ `Admin ; entity.E.admin ] in
    if entity.E.draft then admin else 
      if entity.E.public then `Contact :: admin else 
	entity.E.view :: `Groups (`Any,[entity.E.group]) :: admin
  else []

let has_view_access entity context = 
  MAccess.test context (view_access entity)

let access () id kind =
  let! entity = ohm_req_or (return `Nobody) $ E.Table.get (IEntity.decay id) in
  return ( `Union ((match kind with `View -> view_access | `Manage -> manage_access) entity))

(* A loaded entity ------------------------------------------------------------------------- *)

type 'relation t = {
  id    : 'relation IEntity.id ;
  data  : E.entity ;
  view  : bool O.run ;
  admin : bool O.run ;
}

let make context id data = 
  {
    id    = id ;
    data  = data ;
    admin = has_manage_access data context ;
    view  = has_view_access data context ; 
  }

let make_public id data = 
  if data.E.public && data.E.deleted = None then
    Some {
      id    = IEntity.Assert.view id ;
      data  = data ;
      view  = return true ;
      admin = return false
    }
  else
    None

let make_full id data = 
  {
    id    = id ;
    data  = data ;
    view  = return true ;
    admin = return true 
  }

let make_visible id data = 
  {
    id    = id ;
    data  = data ;
    view  = return true ;
    admin = return false 
  }
    
let make_naked id data = 
  {
    id    = id ;
    data  = data ;
    view  = return false ;
    admin = return false
  }

let id t = t.id
let data t = t.data
let is_admin t = t.admin

(* MAccess rights --------------------------------------------------------------------------- *)

let admin t = 
  t.admin |> Run.map begin function 
    | true -> Some
      {
	id    = IEntity.Assert.admin t.id ;
	data  = t.data ;
	view  = return true ;
	admin = return true
      } 
    | false -> None
  end

let view t =
  t.view |> Run.map begin function
    | true -> Some
      {
	id    = IEntity.Assert.view t.id ;
	data  = t.data ;
	view  = return true ;
	admin = t.admin 
      } 
    | false -> None
  end

let view_access t = t.data.E.view

(* Update the access levels --------------------------------------------------------------- *)

let set id ~who ~view ~admin ~config = 
  E.Store.update ~id:(IEntity.decay id) ~info:(MUpdateInfo.info ~who) ~diffs:[
    `Access view ;
    `Admin (MAccess.optimize admin) ;
    `Config config 
  ] () |> Run.map ignore    
