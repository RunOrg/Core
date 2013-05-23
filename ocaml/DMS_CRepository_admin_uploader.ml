(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common
open DMS_CRepository_admin_common

let delegator repo access = object (self)
  method get = MRepository.Get.uploaders repo
  method set aids = MRepository.Set.uploaders aids repo (access # actor) 
end

let () = define Url.Repo.def_delpick begin fun parents repo access ->

  let back = parents # uploaders # url in

  let wrap body = 
    O.Box.fill (O.decay begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ; parents # uploaders ] 
	method here = parents # delpick # title
	method body = O.decay body
      end)
    end)
  in

  CDelegate.picker `Group back access (delegator repo access) wrap 

end

let () = define Url.Repo.def_uploader begin fun parents repo access -> 

  let pick = Some (parents # delpick # url) in 

  let wrap body = 
    O.Box.fill (O.decay begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # uploaders # title
	method body = O.decay body
      end)	
    end)
  in

  CDelegate.list `Group pick access (delegator repo access) wrap

end
