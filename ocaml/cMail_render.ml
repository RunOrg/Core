(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module Block  = CMail_block
module Footer = CMail_footer

let () = MMail.Compose.setRenderer 
  begin fun ~mid ~uid ~owid ~block ~subject ~payload ~body ~buttons ?iid ?from () -> 

    let! from = ohm begin match from with 
      | None -> return None
      | Some aid -> let! profile = ohm (MAvatar.details aid) in
		    return (profile # name)
    end in

    let! instance = ohm (Run.opt_bind MInstance.get iid) in
    let  footer = match instance with 
      | None          -> Footer.core mid uid owid 
      | Some instance -> Footer.instance mid uid instance
    in

    let! nospam = ohm begin 
      let! iid = req_or (return None) iid in 
      let! current = ohm (MMail.Spam.get uid iid) in
      if current <> None then return None else
	match instance with 
	| None -> return None
	| Some instance -> let! pic = ohm (CPicture.small_opt (instance # pic)) in			   
			   return (Some (object 
			     method link allow = Block.link owid uid iid mid allow
			     method name = instance # name
			     method pic  = pic 
			   end))
    end in    
 
    VMailBrick.render ?nospam ?from subject payload body buttons footer 

  end

