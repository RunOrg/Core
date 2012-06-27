(* © 2012 RunOrg *)

type mini_profile = <
  url  : string ;
  pic  : string ;
  name : string 
>

val mini_profile : 'any IAvatar.id -> mini_profile O.run
