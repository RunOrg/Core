(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_delpick begin fun parents entity access ->

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

  CDelegate.picker `Event back access entity wrap 

end

let () = define UrlClient.Events.def_delegate begin fun parents entity access -> 

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

  CDelegate.list `Event pick access entity wrap

end
