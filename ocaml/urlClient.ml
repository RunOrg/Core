(* © 2012 RunOrg *)

open UrlClientHelper

let all = new dflt "*"

let public = ( object (self) 
  inherit rest "e"
  method build  : MInstance.t -> IEntity.t -> string =
    fun inst entity ->
      self # rest inst [IEntity.to_string entity]
end )
  
let grid   = ( object (self) 
  inherit rest "g"
  method build inst user list =
      self # rest inst [ IAvatarGrid.to_string list ;
			 IAvatarGrid.Deduce.make_list_token user list]
end )
  
let csv   = ( object (self) 
  inherit rest "g/csv"
  method build inst user list =
      self # rest inst [ IAvatarGrid.to_string list ;
			 IAvatarGrid.Deduce.make_list_token user list]
end )
  
let ckgrid = ( object (self) 
  inherit rest "g/chk"
  method build inst user list =
      self # rest inst [ IAvatarGrid.to_string list ;
			 IAvatarGrid.Deduce.make_list_token user list]
end )
    
let cancel = new dflt "cancel"
let ping   = new dflt "ping"

