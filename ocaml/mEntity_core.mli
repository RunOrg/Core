(* © 2012 MRunOrg *)

type entity = {
  archive  : bool ;
  draft    : bool ;
  public   : bool ;
  admin    : MAccess.t ;
  view     : MAccess.t ;
  group    : IGroup.t ;
  creator  : IAvatar.t option ;
  kind     : MEntityKind.t ;
  template : ITemplate.t ;
  instance : IInstance.t ;
  config   : MEntityConfig.t ;
  deleted  : IAvatar.t option ;
  name     : TextOrAdlib.t option ; 
  summary  : string ;
  date     : string option ;
  end_date : string option ;
  picture  : [`GetPic] IFile.id option        
}

module Init : sig
  type t =
      {
	archive  : bool ;
	draft    : bool ;
	public   : bool ;
	admin    : MAccess.t ;
	view     : MAccess.t ;
	group    : IGroup.t ;
	creator  : IAvatar.t option ;
	kind     : MEntityKind.t ;
	template : ITemplate.t ;
	instance : IInstance.t ;
	config   : MEntityConfig.t ;
	deleted  : IAvatar.t option ;
      }
end

module Diff : sig
  type t = 
    [ `Config  of MEntityConfig.Diff.t list
    | `Admin   of MAccess.t 
    | `Access  of [ `Private | `Normal | `Public ]
    | `Status  of [ `Draft | `Active | `Delete of IAvatar.t ]
    | `Version of string
    ]  
end

module Store : sig

  module DataDB : Ohm.CouchDB.DATABASE    

  type t 
  type version 

  val id : t -> IEntity.t
  val version_object : version -> IEntity.t
  val version_diffs : version -> Diff.t list

  val update : 
       id:IEntity.t 
    -> diffs:Diff.t list
    -> info:MUpdateInfo.t
    -> unit
    -> t option O.run

  val create : 
       id:IEntity.t
    -> init:Init.t
    -> diffs:Diff.t list
    -> info:MUpdateInfo.t
    -> unit
    -> t O.run

  val migrate :
        O.ctx # Ohm.Async.manager
    ->  string
    -> (IEntity.t -> Init.t -> Init.t option O.run)
    -> (O.ctx,unit) Ohm.Async.task 

  module Signals : sig
    val version_create : (version, unit O.run) Ohm.Sig.channel
    val update : (t, unit O.run) Ohm.Sig.channel
  end

end

module Design : Ohm.CouchDB.DESIGN
module Format : Ohm.Fmt.READ_FMT with type t = entity
module Table : Ohm.CouchDB.READ_TABLE with type id = IEntity.t and type elt = entity
