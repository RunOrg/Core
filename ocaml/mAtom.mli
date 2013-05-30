(* © 2013 RunOrg *)

type t = <
  id      : IAtom.t ; 
  nature  : IAtom.Nature.t ;
  label   : string ;
  hide    : bool ;
  limited : bool ; 
> ;;

module PublicFormat : Ohm.Fmt.FMT with type t = 
  [ `Saved   of IAtom.t 
  | `Unsaved of IAtom.Nature.t * string
  ] 

val reflect : 
     IInstance.t 
  -> IAtom.Nature.t 
  -> Ohm.Id.t 
  -> ?lim:bool 
  -> ?hide:bool 
  -> string 
  -> (#O.ctx,unit) Ohm.Run.t

val create : 'any MActor.t -> IAtom.Nature.t -> string -> (#O.ctx,IAtom.t option) Ohm.Run.t

val access_register : IAtom.Nature.t -> ([`IsToken] MActor.t -> Ohm.Id.t -> bool O.run) -> unit

module All : sig

  val suggest_public : 
       IInstance.t 
    -> ?nature:IAtom.Nature.t
    -> count:int
    -> string 
    -> (#O.ctx, t list) Ohm.Run.t

  val suggest : 
       'any MActor.t
    -> ?nature:IAtom.Nature.t
    -> count:int
    -> string 
    -> (#O.ctx, t list) Ohm.Run.t

end

val get : 
     actor:'any MActor.t 
  -> IAtom.t 
  -> (#O.ctx,[ `Some of t | `Missing | `Limited of IAtom.Nature.t ]) Ohm.Run.t

val of_json : actor:'any MActor.t -> Ohm.Json.t -> (#O.ctx, string option) Ohm.Run.t
