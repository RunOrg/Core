(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E      = MEvent_core
module Config = MEvent_config
module Can    = MEvent_can

type action = 
  [ `Group  of [ `Manage | `Read | `Write ]
  | `Wall   of [ `Manage | `Read | `Write ]
  | `Album  of [ `Manage | `Read | `Write ]
  | `Folder of [ `Manage | `Read | `Write ]
  ]
    
let access t action = 

  let config = (Can.data t).E.config in 
  let etid   = (Can.data t).E.tid in

  let level = 
    match action with 
      | `Group (`Manage | `Write) -> `Managers
      | `Group `Read -> Config.group_read etid config
      | `Wall `Read 
      | `Album `Read
      | `Folder `Read -> Config.collab_read etid config 
      | `Wall `Write
      | `Album `Write
      | `Folder `Write -> Config.collab_write etid config
      | `Wall `Manage
      | `Album `Manage
      | `Folder `Manage -> `Managers
  in
  
  let! access = ohm begin match level with 
    | `Viewers    -> Can.view_access t
    | `Registered -> Can.member_access t
    | `Managers   -> Can.admin_access t
  end in 
  
  return (`Union access) 
