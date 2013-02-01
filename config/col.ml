(* © 2013 RunOrg *)

open Common
  
let status = 
  column ~view:`Status
    ~label:(adlib "ParticipateFieldState" ~old:"participate.field.state" "Statut")
    (`Self `Status)
    
let date = 
  column ~view:`DateTime
    ~label:(adlib "ParticipateFieldDateShort" ~old:"participate.field.date.short" "Depuis le")
    (`Self `Date) 
    
