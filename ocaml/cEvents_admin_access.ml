(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_access begin fun parents entity access -> 
  
  O.Box.fill begin 
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # access # title
      method body = Asset_Delegate_List.render (object method kind = `Event end)
    end)

  end

end
