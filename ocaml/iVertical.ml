(* © 2012 IRunOrg *)

open Ohm

include PreConfig_VerticalId

type 'rel id = t

let decay id = id

let arg = to_string, of_string

module Assert = struct
end

module Deduce = struct
end
