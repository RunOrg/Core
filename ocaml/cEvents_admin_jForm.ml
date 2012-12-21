(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_jform begin fun parents event access -> 

  let! body = CJoinForm.box access (MEvent.Get.group event) in

  O.Box.fill begin 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # jform # title
      method body = O.decay body
    end)
  end
      
end
