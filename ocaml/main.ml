(* © 2012 RunOrg *) 


open Ohm
open BatPervasives

module Actions = struct
  open MDo
  open MErrorAudit
  open MNews
  open CLogin
  open CMe
  open CWebsite
  open CNetwork
  open CStart
  open CUpload
  open CEvents
  open CGroups
  open CHome
  open CForums
  open CNotifySend
  open CContact
  open Splash
end

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run (Some O.run_async)


