(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common
    
let () = define UrlClient.Members.def_join begin fun parents group access -> 

  let fail = O.Box.fill begin

    let body = Asset_Group_Missing.render (parents # home # url) in

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

  CJoin.box `Group (MGroup.Get.group group) access fail wrapper

end 
