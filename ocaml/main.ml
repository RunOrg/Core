(* © 2012 RunOrg *) 


open Ohm
open BatPervasives

module Actions = struct
  open MDo
  open MErrorAudit
  open CLogin
  open CMe
  open CWebsite
  open CNetwork
end

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run (Some O.run_async)


