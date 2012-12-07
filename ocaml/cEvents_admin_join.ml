(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common
    
let () = define UrlClient.Events.def_join begin fun parents event access -> 

  let fail = O.Box.fill begin

    let body = Asset_Event_DraftNoPeople.render (parents # edit # url) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = body
    end)

  end in 

  let wrapper name body = 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ; parents # people ] 
      method here = return name
      method body = body 
    end)
  in 

  if MEvent.Get.draft event then fail else 
    let gid = MEvent.Get.group event in
    CJoin.box `Event gid access fail wrapper

end 
