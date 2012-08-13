(* © 2012 RunOrg *)

type mini_profile = <
  url  : string ;
  pic  : string ;
  pico : string option ;
  name : string ;
  nameo : string option 
>

val name : 'any IAvatar.id -> string O.run 

val mini_profile : 'any IAvatar.id -> mini_profile O.run

val directory : 'any IAvatar.id list -> Ohm.Html.writer O.run
