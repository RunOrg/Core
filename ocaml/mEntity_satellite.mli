(* © 2012 RunOrg *)

type 'a t = 'a MEntity_can.t 

val access : 
  'any t
  -> [ `Wall   of [ `Read | `Write | `Manage ] 
     | `Folder of [ `Read | `Write | `Manage ] 
     | `Album  of [ `Read | `Write | `Manage ] 
     | `Votes  of [ `Read | `Vote  | `Manage ]
     | `Group  of [ `Read | `Write | `Manage ] ]
  -> MAccess.t

val has_votes : 'any t -> bool   
