(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common
open DMS_CRepository_admin_common

let delegator repo access = object (self)
  method get = MRepository.Get.admins repo
  method set aids = MRepository.Set.admins aids repo (access # actor) 
end

let labels lbl = `DMS_Repo_Admins_Label lbl 

let () = define Url.Repo.def_admpick begin fun parents repo access ->

  let back = parents # admins # url in

  let wrap body = 
    O.Box.fill (O.decay begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ; parents # uploaders ] 
	method here = parents # admins # title
	method body = O.decay body
      end)
    end)
  in

  CDelegate.picker labels back access (delegator repo access) wrap 

end

let () = define Url.Repo.def_admins begin fun parents repo access -> 

  let pick = Some (parents # admpick # url) in 

  let wrap body = 
    O.Box.fill (O.decay begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # admins # title
	method body = O.decay body
      end)	
    end)
  in

  CDelegate.list labels pick access (delegator repo access) wrap

end
