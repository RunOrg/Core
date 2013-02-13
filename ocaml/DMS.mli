(* © 2013 RunOrg *)

module IRepository : sig
  include Ohm.Id.PHANTOM
  module Assert : sig
    val admin : 'any id -> [`Admin] id
    val view  : 'any id -> [`View]  id 
  end
end

module MRepository : sig
  type 'relation t 
  module Vision : Ohm.Fmt.FMT with type t = [ `Normal | `Private of IAvatarSet.t list ]
  module Can : sig
    val view  : 'any t -> (#O.ctx,[`View]  t option) Ohm.Run.t
    val admin : 'any t -> (#O.ctx,[`Admin] t option) Ohm.Run.t
  end
  module Get : sig
    (* Primary properties *)
    val id     :            'any t -> 'any IRepository.id
    val iid    :            'any t -> IInstance.t
    val vision : [<`Admin|`View] t -> Vision.t
    val name   : [<`Admin|`View] t -> string 
    val admins : [<`Admin|`View] t -> IAvatar.t list 
  end
  module All : sig
    val visible : 
         ?actor:'any MActor.t
      -> ?start:IRepository.t
      -> count:int
      -> 'a IInstance.id
      -> (#O.ctx,[`View] t list * IRepository.t option) Ohm.Run.t
  end
  module Set : sig 
    val admins : 
         IAvatar.t list
      -> [`Admin] t
      -> 'any MActor.t
      -> (#O.ctx,unit) Ohm.Run.t
    val info : 
         name:string
      -> vision:Vision.t
      -> [`Admin] t
      -> 'any MActor.t
      -> (#O.ctx,unit) Ohm.Run.t 
  end
  val create : 
       self:'any MActor.t
    -> name:string
    -> vision:Vision.t
    -> iid:'a IInstance.id
    -> (#O.ctx,IRepository.t) Ohm.Run.t
  val get : ?actor:'any MActor.t -> 'rel IRepository.id -> (#O.ctx,'rel t option) Ohm.Run.t
  val view : ?actor:'any MActor.t -> 'rel IRepository.id -> (#O.ctx,[`View] t option) Ohm.Run.t
  val admin : ?actor:'any MActor.t -> 'rel IRepository.id -> (#O.ctx,[`Admin] t option) Ohm.Run.t
  val delete : [`Admin] t -> 'any MActor.t -> (#O.ctx,unit) Ohm.Run.t
  val instance : 'any IRepository.id -> (#O.ctx,IInstance.t option) Ohm.Run.t
end

module Url : sig
  val home : (IWhite.key,string list) Ohm.Action.endpoint 
end
