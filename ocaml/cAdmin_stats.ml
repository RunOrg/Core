(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_stats $ admin_only begin fun cuid req res -> 

  let week = 7. *. 24. *. 3600. in

  let urls = BatList.init 28 (Action.url UrlAdmin.getStats None) in

  let body = Asset_Admin_Stats.render (object
    method users_confirmed  = MUser.Backdoor.count_confirmed
    method users_undeleted  = MUser.Backdoor.count_undeleted
    method users_active     = MAdminLog.active_users ~period:week
    method instances        = MInstance.Backdoor.count
    method instances_active = MAdminLog.active_instances ~period:week 
    method urls = urls 
  end) in

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.stats # title 
    method body  = body
  end) res

end

let () = UrlAdmin.def_getStats $ admin_only begin fun cuid req res ->

  let  days_ago = req # args in 
  let! stats = ohm $ MAdminLog.stats days_ago in 
  
  return $ Action.json [ "stats", MAdminLog.Stats.to_json stats ] res

end
