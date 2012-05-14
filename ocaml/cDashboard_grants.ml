(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives
open O

open CDashboard_common

module Entities = CDashboard_entities

let async ~ctx =
  O.Box.reaction "grants" begin fun self bctx req res ->

    let! entities = ohm $ MEntity.All.get_granting ctx in
    
    (* Hack: simulate reverse order *)
    let entities = List.rev entities in

    let shown = 4 in
    let shown = if List.length entities = shown + 1 then shown + 1 else shown in 

    let! list = ohm $ Run.list_map (Entities.render ctx) (BatList.take shown entities) in
    let remaining = List.length entities - shown in

    let  view = VDashboard.EntityList.render
      (object
	method list = list
	method rest =
	  if list = [] then Some 0 else 
	    if remaining < 2 then None else Some remaining 
       end)
      (ctx # i18n)
    in
    
    return (Action.json (Js.Html.return view) res)

  end

let block ~ctx = 

  return (fun callback -> 
    let! inner = async ~ctx in
    callback (Some (fun bctx (prefix,_) ->
      element
	~icon:VIcon.key
	~url:(UrlR.build (ctx # instance) (bctx # segments) (prefix,`Grants))
	~base:"grants"
	~load:(Some (bctx # reaction_url inner))
	~green:None
	~access:`Public
	~hasdesc:false
    ))
  )  
