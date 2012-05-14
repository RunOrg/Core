(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlClientHelper
open UrlR

let root ()    = ( object (self) 
  inherit [MInstance.t] O.Box.controller (r :> MInstance.t O.Box.root_action) ["e"]
  method build inst entity = 
    self # rest inst [IEntity.to_string entity; "info"]
end )

let discussion inst entity =
  let obj = object (self) 
    inherit [MInstance.t] O.Box.controller (r :> MInstance.t O.Box.root_action) ["e"]
    method build inst entity = 
      self # rest inst [IEntity.to_string entity; "wall"]
  end in
  obj # build inst entity
  
let edit ()    = ( object (self) 
  inherit [MInstance.t] O.Box.controller (r :> MInstance.t O.Box.root_action) ["e"]
  method build inst entity = 
    self # rest inst [IEntity.to_string entity; "edit"]
end )
  
let create     = new dflt "r/entity/create"
  
module Option = struct
    
  let root ()  = ( object (self) 
    inherit [MInstance.t] O.Box.controller (r :> MInstance.t O.Box.root_action) ["members"]
    method build inst category tab = 
      self # rest inst [IGroup.to_string (MGroup.Get.id category);"option";tab]
  end )
    
  let post_colorder () = ( object (self) 
    inherit rest "r/members/option/colorder/post"
    method build inst category = 
      self # rest inst [IGroup.to_string (MGroup.Get.id category)]
  end )
    
  let post_coladdrem () = ( object (self) 
    inherit rest "r/members/option/coladdrem/post"
    method build inst category = 
      self # rest inst [IGroup.to_string (MGroup.Get.id category)]
  end )
    
  let post_fields () = ( object (self) 
    inherit rest "r/members/option/fields/post"
    method build inst category = 
      self # rest inst [IGroup.to_string (MGroup.Get.id category)]
  end )
    
  let sources = ( object (self)
    inherit rest "r/members/sources"
    method build inst ?seg id = 
      self # rest inst (Id.str id :: (match seg with Some seg -> [seg] | None -> []))
  end )
    
  let form_newfield = ( object (self) 
    inherit rest "r/members/option/field/new"
    method build inst ?seg () = 
      self # rest inst (BatList.filter_map (fun x -> x) [seg])
  end )
    
  let form_editfield = ( object (self) 
    inherit rest "r/members/option/field/edit"
    method build inst id = 
      self # rest inst [Id.str id]
  end )
    
  let post_newfield = ( object (self)
    inherit rest "r/members/option/field/new/post"
    method build inst id = 
      self # rest inst [Id.str id]
  end )
    
  let post_editfield = ( object (self)
    inherit rest "r/members/option/field/edit/post"
    method build inst id = 
      self # rest inst [Id.str id]
  end )
    
end

let segments = 
  O.Box.Seg.(UrlSegs.(root ++ root_pages ++ entity_id))

let chat instance eid = 
  UrlR.build instance O.Box.Seg.(segments ++ UrlSegs.entity_tabs) 
    ((((),`Entity), Some (IEntity.decay eid)),`Chat)
  
let participate action = 
  let action = match action with 
    | `Asked    -> "join"
    | `Denied   -> "decline"
    | `Accepted -> "accept"
    | `Removed  -> "leave"
  in ( object (self) 
    inherit rest ("r/participate/" ^ action)
    method build inst entity = 	    
      self # rest inst [IEntity.to_string entity]
  end )

    
