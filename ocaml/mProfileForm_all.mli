(* © 2013 RunOrg *)

val by_avatar :
     IAvatar.t 
  -> [`IsAdmin] MActor.t
  -> ([`Edit] IProfileForm.id * MProfileForm_info.t) list O.run
  
val mine : 
     [`IsToken] MActor.t
  -> ([`View] IProfileForm.id * MProfileForm_info.t) list O.run 

val as_parent :
     IAvatar.t 
  -> [`IsToken] MActor.t
  -> ([`View] IProfileForm.id * MProfileForm_info.t) list O.run
