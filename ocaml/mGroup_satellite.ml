(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E      = MGroup_core
module Config = MGroup_config
module Can    = MGroup_can

type action = 
  [ `Group  of [ `Manage | `Read | `Write ]
  | `Send   of [ `Inbox  | `Mail ]
  ]
    
let access t action = 

  let config = (Can.data t).E.config in 
  let etid   = (Can.data t).E.tid in

  let level = 
    match action with 
      | `Group `Manage 
      | `Group `Write -> `Managers
      | `Group `Read  -> Config.group_read etid config
      | `Send  `Mail  -> `Managers 
      | `Send  `Inbox -> `Registered
  in
  
  match level with 
    | `Viewers    -> Can.view_access t
    | `Registered -> Can.member_access t
    | `Managers   -> Can.admin_access t
  
