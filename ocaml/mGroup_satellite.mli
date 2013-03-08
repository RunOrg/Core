(* © 2013 RunOrg *)

type action = 
  [ `Group  of [ `Manage | `Read | `Write ]
  | `Send   of [ `Inbox  | `Mail ] 
  ]
    
val access : 'any MGroup_can.t -> action -> (#O.ctx,MAccess.t) Ohm.Run.t

