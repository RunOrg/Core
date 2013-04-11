(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module Footer      = CMail_footer

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

    VMailBrick.render ?from subject payload body buttons footer 

  end

