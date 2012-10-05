(* © 2012 RunOrg *)

type t = <
  id      : IInstance.t ;
  key     : IWhite.key ;
  name    : string ;
  theme   : string option ;
  disk    : float ;
  create  : float ;
  seats   : int ;
  usr     : IUser.t ;
  ver     : IVertical.t ;
  pic     : [`GetPic] IFile.id option ;
  install : bool ;
  stub    : bool 
> ;;

module Profile : sig

  type t = <
    id       : IInstance.t ;
    name     : string ;
    key      : IWhite.key ;
    address  : string option ;
    contact  : string option ;
    site     : string option ;
    desc     : MRich.OrText.t option ;
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
      -> desc:MRich.OrText.t option
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
end

val create : 
     pic:[`OwnPic] IFile.id option
  -> who:('any ICurrentUser.id)
  -> key:string 
  -> name:string 
  -> address:string option 
  -> desc:MRich.OrText.t option
  -> site:string option
  -> contact:string option 
  -> vertical:IVertical.t
  -> white:IWhite.t option
  -> [`Created] IInstance.id O.run

val update : 
     [`IsAdmin] IInstance.id
  -> name:string
  -> desc:MRich.OrText.t option
  -> address:string option
  -> site:string option
  -> contact:string option
  -> facebook:string option
  -> twitter:string option
  -> phone:string option
  -> tags:string list
  -> unit O.run

val set_pic : 
     [`IsAdmin] IInstance.id
  -> [`InsPic] IFile.id option
  -> unit O.run 

val by_key        : string -> IInstance.t option O.run
val by_servername : string -> IInstance.t option O.run
val by_url        : string -> IInstance.t option O.run

val key_of_servername : string -> string 

val get : 'any IInstance.id -> (#Ohm.CouchDB.ctx, t option) Ohm.Run.t

val get_free_space : [`SeeUsage] IInstance.id -> float O.run

val free_name : string -> string O.run

val visited : count:int -> 'any ICurrentUser.id -> (#Ohm.CouchDB.ctx, IInstance.t list) Ohm.Run.t
val visit : 'any ICurrentUser.id -> IInstance.t -> unit O.run

module Backdoor : sig

  val count : unit -> int O.run

  val key_by_id : (IInstance.t * string) list O.run

end
