(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_api $ admin_only begin fun cuid req res -> 

  let html = Asset_Admin_Api.render (object
    method endpoints = [ object
      method url   = "http://example/"
      method label = "Example"
    end ]
  end) in

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.api # title 
    method body  = html
  end) res

end
