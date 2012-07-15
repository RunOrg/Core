(* © 2012 RunOrg *)

type 'rel id = PreConfig_TemplateId.t

include Ohm.Fmt.FMT with type t = [`Unknown] id
  
val to_string : 'any id -> string
val of_string : string -> t option

val decay : 'any id -> t

val admin : t
val members : t 
val forum : t 

module Assert : sig
  val can_create       : 'any id -> [`Create] id
end
  
module Deduce : sig
  val make_create_token : [`Create] id -> [<`IsMember|`IsAdmin] IIsIn.id -> string
  val from_create_token : 'any id      -> [<`IsMember|`isAdmin] IIsIn.id -> string -> [`Create] id option
end

