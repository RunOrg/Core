(* © 2013 RunOrg *)

type t = <
  id     : IAtom.t ; 
  nature : IAtom.Nature.t ;
  label  : string ;
> ;;

module PublicFormat : Ohm.Fmt.FMT with type t = 
  [ `Saved   of IAtom.t 
  | `Unsaved of IAtom.Nature.t * string
  ] 

val create : 'any MActor.t -> IAtom.Nature.t -> string -> (#O.ctx,IAtom.t option) Ohm.Run.t

module All : sig

  val suggest : 
       IInstance.t 
    -> ?nature:IAtom.Nature.t
    -> count:int
    -> string 
    -> (#O.ctx, t list) Ohm.Run.t

end

val get : actor:'any MActor.t -> IAtom.t -> (#O.ctx,t option) Ohm.Run.t

val of_json : actor:'any MActor.t -> Ohm.Json.t -> (#O.ctx, string option) Ohm.Run.t
