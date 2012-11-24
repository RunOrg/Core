(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

module T = struct
  type json t = 
    | First   "F" of string option 
    | Request "R" of string * string
    | IsUser      of IUser.t
end

include T
include Fmt.Extend(T)

let log t = 
  OhmTrackLogs.log (to_json t) 
