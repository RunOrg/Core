(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let count = 30

let () = UrlAdmin.def_unsbs $ admin_only begin fun cuid req res -> 

  let! list = ohm $ MUser.Backdoor.unsubscribed ~count in 
  let! time = ohmctx (#time) in 
  
  let choices = 
    Asset_Admin_Unsbs.render 
      (List.map (fun unsbs -> (object
	method time = (unsbs # time, time) 
	method email = unsbs # email 
      end)) list)
  in
  
  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.unsbs # title 
    method body  = choices
  end) res

end

