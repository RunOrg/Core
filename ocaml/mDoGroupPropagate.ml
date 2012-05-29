(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module PropagateArgs = Fmt.Make(struct
  type json t = (IAvatar.t * IAvatar.t * IGroup.t) 
end)

let _ = 

  let propagate = O.async # define "propagate-membership" PropagateArgs.fmt
    begin fun (from,aid,gid) ->
      
      let propagate_to_gid gid =
	
	(* Can write to group during propagation *)
	let  wgid = IGroup.Assert.write gid in
	let  from = IAvatar.Assert.is_self from in 
	
	let! mid     = ohm $ MMembership.as_admin wgid aid in 
	let! current = ohm $ MMembership.get mid in

	let should_add = 
	  match current with None -> true | Some current -> 
	    match current.MMembership.admin with None -> true | Some admin -> 
	      let ok, _, _ = admin in not ok 
	in

	if should_add then
	  MMembership.admin ~from wgid aid [ `Accept true ; `Default true ] 
	else 
	  return ()
	  
      in
      
      let! list = ohm $ MGroup.Propagate.get_direct gid in
      let! _    = ohm $ Run.list_iter propagate_to_gid list in
      
      return () 
	
    end
  in

  let update (mid,t) = 

    if t.MMembership.status = `Member then
      let! _, _, from = req_or (return ()) t.MMembership.admin in
      let  gid = t.MMembership.where in
      let  aid = t.MMembership.who in
      let!  _  = ohm $ propagate ~delay:5.0 (from,aid,gid) in
      return ()
    else
      return ()

  in

  Sig.listen MMembership.Signals.after_update update
