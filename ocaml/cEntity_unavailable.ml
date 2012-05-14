(* © 2012 RunOrg *)

open Ohm.Universal

let box ~i18n = 
  O.Box.leaf
    (fun input _ -> return (VEntity.unavailable ~i18n))
    
