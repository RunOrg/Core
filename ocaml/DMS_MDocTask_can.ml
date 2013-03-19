(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MDocTask_core

type 'rel t = {
  id   : 'rel DMS_IDocTask.id ;
  data : E.t
}

let make id data = { id ; data }
