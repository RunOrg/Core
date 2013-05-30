(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CProfile_admin_common

let delegator pid = 
  let! parents = ohm $ O.decay (MProfile.get_parents pid) in 
  return (object
    method get = parents
    method set = MProfile.set_parents pid
  end)

let labels x = `Profile_Viewers_Label x 

let () = define UrlClient.Profile.def_viewPick begin fun parents pid access ->

  let back = parents # viewers # url in

  let! delegator = ohm $ delegator pid in 

  let wrap body = 
    O.Box.fill begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ; parents # viewers ] 
	method here = parents # viewpick # title
	method body = O.decay body
      end)
    end
  in

  CDelegate.picker labels back access delegator wrap 

end

let () = define UrlClient.Profile.def_viewers begin fun parents pid access -> 

  let pick = Some (parents # viewpick # url) in 

  let! delegator = ohm $ delegator pid in 

  let wrap body = 
    O.Box.fill begin 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # viewers # title
	method body = O.decay body
      end)	
    end
  in

  CDelegate.list ~admins:false labels pick access delegator wrap

end
