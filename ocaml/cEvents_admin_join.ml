(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_join begin fun parents entity access -> 

  let! aid = O.Box.parse IAvatar.seg in 

  O.Box.fill begin 

    let! profile = ohm $ O.decay (CAvatar.mini_profile aid) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ; parents # people ] 
      method here = return (profile # name) 
      method body = return ignore
    end)

  end


end 
