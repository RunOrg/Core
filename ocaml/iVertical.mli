(* © 2012 RunOrg *)

type 'rel id = PreConfig_VerticalId.t

include Ohm.Fmt.FMT with type t = [`Unknown] id
  
val to_string : 'any id -> string
val of_string : string -> t option

val decay : 'any id -> t
    
module Assert : sig 
end

module Deduce : sig 
end
