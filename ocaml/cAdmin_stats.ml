(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_stats $ admin_only begin fun cuid req res -> 

  let urls = BatList.init 28 (Action.url UrlAdmin.getStats None) in

  let choices = Asset_Admin_Stats.render (object
    method urls = urls 
  end) in

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.stats # title 
    method body  = choices
  end) res

end

let () = UrlAdmin.def_getStats $ admin_only begin fun cuid req res ->

  let  days_ago = req # args in 
  let! stats = ohm $ MAdminLog.stats days_ago in 
  
  return $ Action.json [ "stats", MAdminLog.Stats.to_json stats ] res

end
