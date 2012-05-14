(* © 2012 RunOrg *)

open Ohm
open BatPervasives

let make (text,icon,action) = object
  method text   = text
  method icon   = icon
  method action = action
end
