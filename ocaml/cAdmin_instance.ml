(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_instance $ admin_only begin fun cuid req res ->

  let fail = page cuid "Instance" (object
    method parents = [ Parents.home ]
    method here = return "Association Non Trouvée" 
    method body = return ignore
  end) res in

  let  iid = req # args in 
  let! profile = ohm_req_or fail (MInstance.Profile.get iid) in
  let! pic = ohm (CPicture.large (profile # pic)) in

  let body = Asset_Admin_Instance.render (object
    method pic  = pic
    method name = profile # name
    method root = Action.Convenience.root O.client (profile # key) 
  end) in

  page cuid "Instance" (object
    method parents = [ Parents.home ]
    method here = return (profile # name) 
    method body = body
  end) res

end 
