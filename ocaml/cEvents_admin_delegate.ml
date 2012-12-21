(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let delegator event access = object
  method get = MEvent.Get.admins event
  method set = MEvent.Set.admins event (access # self) 
end

let () = define UrlClient.Events.def_delpick begin fun parents event access ->

  let back = parents # delegate # url in

  let wrap body = 
    O.Box.fill begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ; parents # delegate ] 
	method here = parents # delpick # title
	method body = O.decay body
      end)
    end
  in

  CDelegate.picker `Event back access (delegator event access) wrap 

end

let () = define UrlClient.Events.def_delegate begin fun parents event access -> 

  let pick = Some (parents # delpick # url) in 

  let wrap body = 
    O.Box.fill begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # delegate # title
	method body = O.decay body
      end)	
    end
  in

  CDelegate.list `Event pick access (delegator event access) wrap

end
