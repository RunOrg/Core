(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

module Grid = MAvatarGrid

let () = define UrlClient.Events.def_people begin fun parents entity access -> 
  
  O.Box.fill begin 
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = return ignore
    end)

  end

end
