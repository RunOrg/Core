(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
end

module Deduce : sig
end

module View : sig
  type t
  val of_id : Ohm.Id.t -> t
  val to_id : t -> Ohm.Id.t 
  val make : 'a id -> 'b IAvatar.id -> t 
end
