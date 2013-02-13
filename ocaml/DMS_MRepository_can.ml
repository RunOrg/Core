(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MRepository_core

include HEntity.Can(struct

  type core = E.t
  type 'a id = 'a DMS_IRepository.id

  let deleted e = e.E.del <> None
  let iid     e = e.E.iid
  let admin   e = [ `Admin ; e.E.admins ]

  let view e = 
    match e.E.vision with 
      | `Normal        -> [ `Token ]
      | `Private asids -> `Groups (`Any,asids) :: admin e
	
  let id_view  id = DMS_IRepository.Assert.view id
  let id_admin id = DMS_IRepository.Assert.admin id 
  let decay    id = DMS_IRepository.decay id 

  let public _ = false

end)

