(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Actions = struct
  open MDo
  open MErrorAudit
  open MNews
  open CAvatarExport
  open CExport
  open CAdmin
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
  open CSplash
  open CProfile
  open CPortal
  open CHelp
  open Splash
end

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run ~async:O.run_async O.role


