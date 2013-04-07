(* © 2013 RunOrg *) 

module Types = MNotif_types
module All   = MNotif_all 
module Send  = MNotif_send
module Zap   = MNotif_zap 

include MNotif_plugins

let send f = 
  Send.one f

let zap_unread cuid = 
  Zap.unread (IUser.Deduce.is_anyone cuid) 
