(* © 2012 RunOrg *)

open Ohm

(* A text message --------------------------------------------------------------------------- *)

module Text = struct
  module T = struct
    type json t = {
      text_author   "usr" : IAvatar.t ;
      text_contents "txt" : string ;
      text_time     "tim" : float
    }
  end
  include T 
  include Fmt.Extend(T)
end

type text = Text.t = {
  text_author   : IAvatar.t ;
  text_contents : string ;
  text_time     : float
}

(* Payload variant definition -------------------------------------------------------------- *)

module Payload = Fmt.Make(struct
  type json t = 
    [ `text of Text.t
    ]
end)

type payload = Payload.t

(* Main object definition *)

include Fmt.Make(struct
  type json t = <
    id      "i" : Id.t ;
    payload "p" : Payload.t
  >
end)

let make id payload = object
  method id      = id
  method payload = payload
end

let author = function
  | `text t -> t.text_author

let payload = (#payload)
