(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common
open DMS_CDocument_admin_common

let () = define Url.Doc.def_delete begin fun parents rid doc access ->
  O.Box.fill begin 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ]
      method here = parents # share # title
      method body = return (Html.str "")
    end)
  end 
end
