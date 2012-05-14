(* © 2012 RunOrg *)

type text = {
  text_author   : IAvatar.t ;
  text_contents : string ;
  text_time     : float
}

module Payload : Ohm.Fmt.FMT with type t = 
  [ `text of text ]

include Ohm.Fmt.FMT with type t = <
  id      : Ohm.Id.t ;
  payload : Payload.t
>

val make : Ohm.Id.t -> Payload.t -> t

val author : Payload.t -> IAvatar.t

val payload : t -> Payload.t
