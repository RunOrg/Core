(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_sqlize $ admin_only begin fun cuid req res -> 

  let! count_users = ohm MUser.Backdoor.count_undeleted in
  let! count_instances = ohm MInstance.Backdoor.count in
  let! count_avatars = ohm MAvatar.Backdoor.count in

  let choices = Asset_Admin_Sqlize.render (object
    method count = count_users + count_instances + count_avatars  
    method url   = Action.url UrlAdmin.getSQL None (0,None)
  end) in

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.sqlize # title 
    method body  = choices
  end) res

end
    
