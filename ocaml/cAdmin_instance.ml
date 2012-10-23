(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_mksearch $ admin_only begin fun cuid req res ->

  let back = return $ Action.redirect (Action.url UrlAdmin.instance (req # server) (req # args)) res in

  if req # post = None then back else

    let  iid = req # args in 
    let! p   = ohm_req_or back (MInstance.Profile.get iid) in
    let! ()  = ohm $ MInstance.Profile.Backdoor.update iid 
      ~name:(p # name)
      ~key:(p # key)
      ~pic:(BatOption.map IFile.decay (p # pic))
      ~phone:(p # phone)
      ~desc:(p # desc)
      ~site:(p # site)
      ~address:(p # address)
      ~contact:(p # contact)
      ~facebook:(p # facebook)
      ~twitter:(p # twitter)
      ~tags:(p # tags)
      ~visible:true
      ~rss:(List.map fst (p # pub_rss))
      ~owners:(BatOption.default [] (p # unbound))
    in

    back

end 

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
    method search = profile # search
    method addsearch = Action.url UrlAdmin.mksearch (req # server) (req # args) 
  end) in

  page cuid "Instance" (object
    method parents = [ Parents.home ]
    method here = return (profile # name) 
    method body = body
  end) res

end 
