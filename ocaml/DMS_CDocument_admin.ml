(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 
open DMS_CDocument_admin_common

let () = define Url.Doc.def_admin begin fun parents rid doc access ->
  O.Box.fill begin 

    let choices = Asset_Admin_Choice.render [
    ] in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ]
      method here = parents # admin # title
      method body = choices
    end)
  end 
end
