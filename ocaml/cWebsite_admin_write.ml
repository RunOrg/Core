(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CWebsite_admin_common

let _ = CClient.define UrlClient.Website.def_write begin fun access -> 

  O.Box.fill (wrap access `EMPTY (return ignore)) 

end 
