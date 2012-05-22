(* © 2012 RunOrg *)

type t = <
  id      : IInstance.t ;
  key     : string ;
  name    : string ;
  theme   : string option ;
  disk    : float ;
  create  : float ;
  seats   : int ;
  usr     : IUser.t ;
  ver     : IVertical.t ;
  pic     : [`GetPic] IFile.id option ;
  version : string ;
  install : bool ;
  light   : bool ;
  trial   : bool ;
  stub    : bool ;
  white   : IWhite.t option
> ;;

module Profile : sig

  type t = <
    id       : IInstance.t ;
    name     : string ;
    key      : string ;
    address  : string option ;
    contact  : string option ;
    site     : string option ;
    desc     : string option ;
    twitter  : string option ;
    facebook : string option ;
    phone    : string option ;
    tags     : string list ;
    pic      : [`GetPic] IFile.id option ;
    search   : bool ;
    unbound  : bool ;
    pub_rss  : ( string * IPolling.RSS.t ) list 
  > ;;

  val empty : IInstance.t -> t 

  val get : 'any IInstance.id -> t option O.run

  val by_tag :
       ?start:IInstance.t
    ->  count:int
    ->  string
    ->  (t list * IInstance.t option) O.run

  val tag_stats : unit -> (string * int) list O.run

  val all : 
       ?start:IInstance.t
    ->  count:int
    ->  unit
    ->  (t list * IInstance.t option) O.run


  val by_rss : IPolling.RSS.t -> IInstance.t list O.run

  module Backdoor : sig

    val count : unit -> int O.run

    val update : 
         IInstance.t
      -> name:string
      -> key:string 
      -> pic:IFile.t option
      -> phone:string option
      -> desc:string option
      -> site:string option
      -> address:string option
      -> contact:string option
      -> facebook:string option
      -> twitter:string option
      -> tags:string list
      -> visible:bool
      -> rss:string list
      -> unit O.run

  end

end

module Signals : sig

  val on_create  : ( [`Created] IInstance.id, 
		     unit O.run ) Ohm.Sig.channel

  val on_upgrade : ( [`Unknown] IInstance.id * MPreConfig.VerticalDiff.t list, 
		     unit O.run ) Ohm.Sig.channel
end

val create : 
     pic:[`OwnPic] IFile.id option
  -> who:([`IsSelf] IUser.id)
  -> key:string 
  -> name:string 
  -> address:string option 
  -> desc:string option
  -> site:string option
  -> contact:string option 
  -> vertical:IVertical.t
  -> [`Created] IInstance.id O.run

val create_stub : 
     who:([`IsSelf] IUser.id)
  -> name:string 
  -> desc:string option
  -> site:string option
  -> profile:IInstance.t option
  -> [`Created] IInstance.id O.run

val update : 
     [`Update] IInstance.id
  -> pic:[`InsPic] IFile.id option
  -> name:string
  -> desc:string option
  -> address:string option
  -> site:string option
  -> contact:string option
  -> facebook:string option
  -> twitter:string option
  -> phone:string option
  -> tags:string list
  -> unit O.run

val by_key        : string -> IInstance.t option O.run
val by_servername : string -> IInstance.t option O.run
val by_url        : string -> IInstance.t option O.run

val key_of_servername : string -> string 

val get : 'any IInstance.id -> (#Ohm.CouchDB.ctx, t option) Ohm.Run.t

val get_free_space : [`SeeUsage] IInstance.id -> float O.run

val free_name : string -> string O.run

val visited : count:int -> 'any ICurrentUser.id -> (#Ohm.CouchDB.ctx, IInstance.t list) Ohm.Run.t
val visit : count:int -> 'any ICurrentUser.id -> IInstance.t option -> IInstance.t list O.run

val first_unapplied_version : (IInstance.t option * string) O.run
val upgrade : ?upto:string -> IInstance.t -> unit O.run

module Backdoor : sig

  val count : unit -> int O.run

  val key_by_id : (IInstance.t * string) list O.run

end
