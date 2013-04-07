(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Actions = struct

  open MNotif

  (* High-level action tasks *)
  open MDo

  (* Active controllers *)
  open CAtom
  open CAvatarExport
  open CDiscussion
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
  open CNotifySend
  open CContact
  open CSplash
  open CProfile
  open CPortal
  open CHelp
  open CSearch
  open CInbox

  (* Standalone splash page *)
  open Splash

  (* Plugins *)
  open DMS

  (* Pacemaker *)
  open ConfigPacemkr

end

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run ~async:O.run_async O.role


