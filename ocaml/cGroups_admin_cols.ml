(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

let () = define UrlClient.Members.def_cols begin fun parents group access -> 

  let! body = CGrid.Columns.box access (MGroup.Get.group group) in

  O.Box.fill begin 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ; parents # people ] 
      method here = parents # cols # title
      method body = O.decay body
    end)
  end
      
end
