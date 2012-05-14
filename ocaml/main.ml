(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Actions = struct
  open MDo
  open CLogin
end

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run (Some O.run_async)


