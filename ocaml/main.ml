(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Actions = struct
  open MDo
end

module Main = Ohm.Main.Make(O.Action)(MModel.Reset)(MModel.Template)(MModel.Task)
let _ = Main.run ()
