(* © 2013 RunOrg *)

type store = IFile.Storage.t * Ohm.Json.t
include Ohm.Fmt.FMT with type t = store

module type STORAGE = sig
  module Handle   : Ohm.Fmt.FMT
  module UpHandle : Ohm.Fmt.FMT
  include Ohm.Fmt.FMT   
  val id : IFile.Storage.t
  val owner : t -> [ `User of IUser.t | `Instance of IInstance.t ]
  val prepare : 
       maxsize:float
    -> t 
    -> (#O.ctx, < 
         handle : UpHandle.t ; 
         form   : string -> <
           post   : (string * string) list ; 
	   key    : string ; 
           url    : string 
         >
       > option) Ohm.Run.t
  val find : UpHandle.t -> t -> (#O.ctx,Handle.t option) Ohm.Run.t
  val url : Handle.t -> t -> (#O.ctx,string option) Ohm.Run.t
  val upload : 
       public:bool 
    -> filename:string 
    -> string 
    -> t
    -> (#O.ctx, Handle.t option) Ohm.Run.t
  val download : Handle.t -> t -> (#O.ctx,< 
    filename : string ; 
    local    : string ;
    size     : float  ;
  > option) Ohm.Run.t
  val delete : Handle.t -> t -> (#O.ctx,unit) Ohm.Run.t
end

module RegisterStorage : functor(S:STORAGE) -> sig
  type t = S.t
  val make : t -> store
end

type ('ctx) provider = <
  owner : [ `User of IUser.t | `Instance of IInstance.t ] ;
  find : Ohm.Json.t -> ('ctx,Ohm.Json.t option) Ohm.Run.t ;
  url  : Ohm.Json.t -> ('ctx,string option) Ohm.Run.t ;
  prepare : maxsize:float -> ('ctx, <
    handle : Ohm.Json.t ;
    form   : string -> <
      post   : (string * string) list ;
      key    : string ;
      url    : string
    >
  > option) Ohm.Run.t ;
  upload : public:bool -> filename:string -> string -> ('ctx, Ohm.Json.t option) Ohm.Run.t ;
  download : Ohm.Json.t -> ('ctx,<
    filename : string ;
    local    : string ;
    size     : float ;
  > option) Ohm.Run.t ;
  delete : Ohm.Json.t -> ('ctx,unit) Ohm.Run.t
> 

val provider : store -> #O.ctx provider option
