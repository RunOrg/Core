(* © 2013 RunOrg *)

type mini_profile = <
  url  : string ;
  pic  : string ;
  pico : string option ;
  name : string ;
  nameo : string option 
>

val name : 'any IAvatar.id -> string O.run 

val mini_profile : 'any IAvatar.id -> mini_profile O.run
val mini_profile_from_details : 'any IAvatar.id -> MAvatar.details -> mini_profile O.run

val directory : 
     ?url:('any IAvatar.id -> string)
  -> 'any IAvatar.id list
  -> Ohm.Html.writer O.run
