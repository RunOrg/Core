(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.migrate

  module Format = Fmt.Make(struct
    type json t = [ `AvatarAtoms ]
  end)

  let example = `AvatarAtoms
    
  let action cuid json =
    match json with 
      | `AvatarAtoms -> let! () = ohm (MAvatar.Backdoor.refresh_avatar_atoms ()) in
			ok "Avatar atom refresh started !"

end)
