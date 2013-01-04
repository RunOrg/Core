(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Actions = struct
  open MDo
  open MErrorAudit
  open MNews
  open CAvatarExport
  open CDiscussion
  open CExport
  open CAdmin
  open CLogin
  open MDiscussion_migrate
  open CMe
  open CWebsite
  open CNetwork
  open CStart
  open CUpload
  open CEvents
  open CGroups
  open CNotifySend
  open CContact
  open CSplash
  open CProfile
  open CPortal
  open CHelp
  open CSearch
  open CVoeux
  open CInbox
  open Splash
end

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run ~async:O.run_async O.role


