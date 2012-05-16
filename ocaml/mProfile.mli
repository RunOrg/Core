(* © 2012 RunOrg *)

module Data : sig

  type t = {
    firstname : string ;
    lastname  : string ;
    email     : string option ;
    birthdate : string option ;
    phone     : string option ;
    cellphone : string option ;
    address   : string option ;
    zipcode   : string option ;
    city      : string option ;
    country   : string option ;
    picture   : [`GetPic] IFile.id option ;
    gender    : [`m|`f] option 
  }
    
  type extract = [ `firstname 
		 | `lastname 
		 | `email 
		 | `birthdate
		 | `phone
		 | `cellphone 
		 | `address
		 | `zipcode
		 | `city
		 | `country
		 | `gender ]
      
  val extract : t -> extract -> Json_type.t
    
end


module Signals : sig

  val on_create : ( [`Created] IProfile.id * IUser.t * IInstance.t * Data.t, 
		    unit O.run ) Ohm.Sig.channel

  val on_update : ( [`Updated] IProfile.id * IUser.t * IInstance.t * Data.t,
		    unit O.run ) Ohm.Sig.channel

  val on_obliterate : (IProfile.t * IUser.t * IInstance.t, unit O.run) Ohm.Sig.channel

end

val find : IInstance.t -> IUser.t -> IProfile.t option O.run

val find_view : [`ViewProfile] IInstance.id -> IUser.t -> [`View] IProfile.id option O.run

val find_self : [<`IsAdmin|`IsToken|`IsContact] IIsIn.id -> [`IsSelf] IProfile.id O.run

val refresh   : [`Bot] IUser.id -> 'b IInstance.id -> unit O.run

val create : 'any IInstance.id -> Data.t -> 
  [ `ok of (IUser.t * [`Created] IProfile.id) | `exists of IUser.t ] O.run
    
val data : [`View] IProfile.id -> (MFieldShare.t list * Data.t) option O.run

module Sharing : sig

  val get : [`View] IProfile.id -> MFieldShare.t list option O.run
  val set : [`IsSelf] IProfile.id -> MFieldShare.t list option -> unit O.run

end

type details = <
  firstname : string ;
  lastname : string ;
  email : string option ; 
  picture : [`GetPic] IFile.id option 
>

val details : [`IsSelf] IProfile.id -> details option O.run
