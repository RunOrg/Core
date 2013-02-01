(* © 2013 RunOrg *)

type action = 
  [ `Group  of [ `Manage | `Read | `Write ]
  | `Wall   of [ `Manage | `Read | `Write ]
  | `Album  of [ `Manage | `Read | `Write ]
  | `Folder of [ `Manage | `Read | `Write ]
  ]
    
val access : 'any MEvent_can.t -> action -> MAccess.t
