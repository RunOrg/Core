(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let print amount = 
  Printf.sprintf "%.02f €" (float_of_int amount /. 100.)
