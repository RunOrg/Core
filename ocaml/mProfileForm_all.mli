(* © 2012 RunOrg *)

val by_avatar :
     IAvatar.t 
  -> [`Admin] # MAccess.context
  -> ([`Edit] IProfileForm.id * MProfileForm_info.t) list O.run
  
val mine : 
     [`IsToken] # MAccess.context
  -> ([`View] IProfileForm.id * MProfileForm_info.t) list O.run 
