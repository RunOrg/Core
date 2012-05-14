(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let entities ~(ctx:'any CContext.full) ~label ?minitip seed =  

  let! entities = ohm (MEntity.All.get ctx) in

  let extract e = 
    
    let id     = MEntity.Get.id e in 
    let name   = CName.of_entity e in      
    let kind   = MEntity.Get.kind e in
    
    let! pic = ohm (ctx # picture_small (MEntity.Get.picture e)) in

    let render i18n = 
      let html, _ = View.extract (VAccess.Autocomplete.render (object
	method name = name
	method kind = kind
	method pic  = pic 
      end) i18n) in
      View.str html
    in
    
    return $ Some (id, name, Some render)
  in

  let! static = ohm $ Run.list_map extract entities in
  let  static = BatList.filter_map identity static in

  let select = 
    VQuickForm.mini_select
      ~format:IEntity.fmt 
      ~source:(`Static static)
      (fun _ init -> Some init) 
      (fun _ _ value -> Ok value)
  in

  let field = 
    VQuickForm.fieldArray 
      ~add:(`label "entity.list.add") 
      ~label 
      ?minitip
      select
    |> Joy.seed_map (fun data -> seed data)
    |> Joy.result_map (BatList.filter_map identity)
  in

  return field
  
