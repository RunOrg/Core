(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Tree = struct

  module EntityType = MEntityKind
  type param  = ([`View] IEntity.id -> JsCode.t) * [`IsToken] MAccess.context
  
  include Fmt.Make(struct
    type json t = [ `Root | `Node of EntityType.t ]
  end)
    
  let node (use_entity,ctx) i18n node = 
    let bullet = VIcon.bullet_black in
    let _i t = I18n.translate i18n (`label t) in
    match node with 
      | `Root ->
	return
	  (List.map begin fun kind ->
	    CPicker.node 
	      ~title:(I18n.translate i18n (VLabel.of_entity_kind `plural kind))
	      ~icon:(VIcon.of_entity_kind kind) 
	      (`Node kind)
	  end MEntityKind.all)
      | `Node kind -> 
	let! list = ohm $ MEntity.All.get_by_kind ctx kind in
	let  list = List.sort (fun a b -> compare (MEntity.Get.id b) (MEntity.Get.id a)) list in
	return $ List.map begin fun entity ->
	  CPicker.item 
	    ~title:(match MEntity.Get.name entity with 
	      | Some name -> I18n.translate i18n name 
	      | None -> _i "entity.untitled")
	    ~icon:bullet
	    (use_entity (MEntity.Get.id entity))
	end list      
end

module Picker = CPicker.Make(Tree)

