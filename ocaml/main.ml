(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Actions = struct
  open MDo
  open CAccess
  open CAccounting
  open CActionList
  open CAdmin
  open CAlbum
  open CApi
  open CAssoOptions
  open CAvatar
  open CCatalog
  open CChat
  open CClient
  open CConfirm
  open CContacts
  open CContext
  open CCore
  open CDashboard
  open CEntityCreate
  open CEntityForm
  open CEntity
  open CEntityTree
  open CFeed
  open CField
  open CFile
  open CFolder
  open CFunnel
  open CGender
  open CGrid
  open CHelper
  open CHelp
  open CImage
  open CInstance
  open CItem
  open CJoin
  open CLists
  open CLogin
  open CMember
  open CMe
  open CMessage
  open CMiniPoll
  open CMoreActions
  open CMyOptions
  open CName
  open CNotification
  open CPaging
  open CPayment
  open CPicker
  open CPicture
  open CPreserve
  open CProfile
  open CSegs
  open CSend
  open CSession
  open CSondage
  open CSplash
  open CStats
  open CSubscriptions
  open CTabs
  open CWall
  open GSplash
end

module Main = Ohm.Main.Make(O.Action)(MModel.Reset)(MModel.Template)(MModel.Task)
let _ = Main.run ()
