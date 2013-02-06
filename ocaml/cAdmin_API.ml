(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

module AddInstanceAdmin    = CAdmin_API_addInstanceAdmin
module EditInstanceProfile = CAdmin_API_editInstanceProfile
module Reboot              = CAdmin_API_reboot
module RenameInstance      = CAdmin_API_renameInstance
module ConfirmUser         = CAdmin_API_confirmUser
module SetPlugins          = CAdmin_API_setPlugins

let () = UrlAdmin.def_api $ admin_only begin fun cuid req res -> 

  let html = Asset_Admin_Api.render (object
    method endpoints = UrlAdmin.API.all_endpoints (req # server)
  end) in

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.api # title 
    method body  = html
  end) res

end

