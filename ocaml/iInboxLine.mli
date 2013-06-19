(* © 2013 RunOrg *)

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

module Filter : sig
  include Ohm.Fmt.FMT with type t = 
		  [ `All 
		  | `HasFiles
		  | `HasPics 
		  | `Events
		  | `Groups
		  | `Private
		  | `Group of IGroup.t ]
  val to_string : t -> string
  val of_string : string -> t
  val seg : t OhmBox.Seg.t
  val largest : t
  val smallest : t
end 
