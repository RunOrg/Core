(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

let () = define UrlClient.Members.def_delpick begin fun parents entity access ->

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

  CDelegate.picker `Group back access entity wrap 

end

let () = define UrlClient.Members.def_delegate begin fun parents entity access -> 

  let! is_admin = ohm (O.decay (MEntity.is_admin entity)) in

  let pick = if is_admin then None else Some (parents # delpick # url) in 

  let wrap body = 
    O.Box.fill begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # delegate # title
	method body = O.decay body
      end)	
    end
  in

  CDelegate.list `Group pick access entity wrap

end
