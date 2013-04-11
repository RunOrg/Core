(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let rec clip yyyy mm = 
  if mm < 0 then clip (yyyy - 1) (mm + 12) else
    if mm >= 12 then clip (yyyy + 1) (mm - 12) else
      Printf.sprintf "%02d / %04d" (mm + 1) yyyy

let () = UrlAdmin.def_public $ admin_only begin fun cuid req res -> 

  let  ago = BatOption.default 0 (req # args) in

  let! list = ohm $ MBroadcast.Backdoor.active_instances cuid ago in 

  let! items = ohm $ Run.list_filter begin fun (iid,count) ->
    let! instance = ohm_req_or (return None) $ MInstance.get iid in
    let  url = Action.url UrlAdmin.instance None iid in
    let! pic = ohm $ CPicture.small_opt (instance # pic) in    
    return $ Some (object
      method url   = url
      method key   = fst instance # key
      method name  = instance # name
      method count = count
      method pic   = pic
     end) 
  end list in

  let! time = ohmctx (#time) in
  let  date = Unix.gmtime time in
  let  date = Unix.(clip (date.tm_year + 1900) (date.tm_mon - ago)) in

  let choices = Asset_Admin_PublicInstances.render (object
    method list = items 
    method prev = Action.url UrlAdmin.public None (Some (ago + 1))
    method date = date
  end) in

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.public # title 
    method body  = choices
  end) res

end
