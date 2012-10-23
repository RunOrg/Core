(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_api $ admin_only begin fun cuid req res -> 

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.api # title 
    method body  = return ignore 
  end) res

end
