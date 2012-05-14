(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlClientHelper
open UrlR

let edit () = ( object (self)
  inherit [MInstance.t] O.Box.controller (r :> MInstance.t O.Box.root_action) ["e"]
  method build_base inst entity = 	    
    self # rest inst [IEntity.to_string entity;"p"]
  method build inst entity avatar =	    
    self # rest inst [IEntity.to_string entity;
		      "p";
		      IAvatar.to_string avatar] 			      
end )

let self_edit = object (self)
  inherit rest "j/self-edit"
  method build inst (eid:IEntity.t) = self # rest inst [IEntity.to_string eid] 
end

let self_edit_post = object (self)
  inherit rest "j/self-edit-post"
  method build inst (eid:IEntity.t) = self # rest inst [IEntity.to_string eid] 
end

let self_quit = object (self)
  inherit rest "j/self-quit"
  method build inst (eid:IEntity.t) = self # rest inst [IEntity.to_string eid] 
end
  
let remove () = ( object (self)
  inherit rest "j/remove"
  method build inst category avatar =
    self # rest inst [IGroup.to_string (MGroup.Get.id category); 
		      IAvatar.to_string avatar]       
end )
