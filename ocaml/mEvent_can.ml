(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MEvent_core

type 'relation t = {
  eid    : 'relation IEvent.id ;
  data   : E.t ;
  access : [`IsToken] MAccess.context option ; 
}

let make eid ?access data = {
  eid ;
  data ;
  access = BatOption.bind begin fun access ->
    match IIsIn.Deduce.is_token (access # isin) with 
      | None -> None
      | Some isin -> Some (object
	method self = access # self
	method isin = isin 
      end)
  end access
}
  
let admins t = 
  [ `Admin ; t.data.E.admins ]

let members  t = 
  `Groups (`Validated,[ t.data.E.gid ]) :: admins t

let id t = t.eid

let data t = t.data

let view t = 
  Run.edit_context (fun ctx -> (ctx :> O.ctx)) begin 
    let t' = { eid = IEvent.Assert.view t.eid ; data = t.data ; access = t.access } in
    if t.data.E.draft then 
      match t.access with
	| None        -> return None
	| Some access -> let! ok = ohm $ MAccess.test access (admins t) in
			 if ok then return (Some t') else return None
    else
      match t.data.E.vision with 
	| `Public  -> return (Some t')
	| `Normal  -> if t.access <> None then return (Some t') else return None
	| `Private -> match t.access with 
	    | None        -> return None
	    | Some access -> let! ok = ohm $ MAccess.test access (members t) in
			     if ok then return (Some t') else return None
  end
    
let admin t = 
  Run.edit_context (fun ctx -> (ctx :> O.ctx)) begin
    let t' = { eid = IEvent.Assert.admin t.eid ; data = t.data ; access = t.access } in
    match t.access with 
      | None        -> return None
      | Some access -> let! ok = ohm $ MAccess.test access (admins t) in
		       if ok then return (Some t') else return None
  end
