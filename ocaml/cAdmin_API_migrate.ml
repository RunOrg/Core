(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.migrate

  module Format = Fmt.Make(struct
    type json t = 
      [ `AvatarAtoms 
      | `Digest 
      | `GroupAtoms 
      | `EventAtoms
      ]
  end)

  let example = `AvatarAtoms
    
  let action cuid json =
    match json with 
      | `AvatarAtoms -> let! () = ohm (MAvatar.Backdoor.refresh_avatar_atoms ()) in
			ok "Avatar atom refresh started !"
      | `Digest      -> let! () = ohm (MDigest.Backdoor.migrate_confirmed ()) in
			ok "User digest import started !"
      | `GroupAtoms  -> let! () = ohm (MGroup.Backdoor.refresh_atoms cuid) in
			ok "Group atom refresh started !"
      | `EventAtoms  -> let! () = ohm (MEvent.Backdoor.refresh_atoms cuid) in
			ok "Event atom refresh started !"

end)
