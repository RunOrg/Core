(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Actions = struct
  open MDo
end

module Main = Ohm.Main.Make(MModel.Reset)
let _ = Main.run O.run_async
