(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

let () = define UrlClient.Members.def_jform begin fun parents group access -> 

  let! body = CJoinForm.box access (MGroup.Get.group group) in

  O.Box.fill begin 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # jform # title
      method body = O.decay body
    end)
  end
      
end
