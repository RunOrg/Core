(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.edit_instance_profile

  module Format = Fmt.Make(struct
    type json t = <
      name : string ;
      url  : string ;
     ?address : string option ;
     ?tags : string list = [] ;
      owners : string list
    >
  end)

  let example = (object
    method name = "Football Club Paris XXe"
    method url  = "fc75020.runorg.com"
    method address = Some "22 rue Planchat, 75020 Paris"
    method tags = [ "football" ; "sport" ; "club" ; "paris" ]
    method owners = [ "vnicollet@runorg.com" ; "mfoughali@runorg.com" ]
  end)
    
  let action cuid json =

    let  domain = json # url in 
    let  okey, owid = ConfigWhite.slice_domain domain in
    let! key = req_or (fail "Domaine inconnu: '%s'" domain) okey in

    let! iid_opt = ohm $ MInstance.Profile.Backdoor.by_key (key,owid) in
    let  iid = match iid_opt with Some iid -> iid | None -> IInstance.gen () in

    let! profile_opt = ohm $ MInstance.Profile.get iid in 
    let  profile = match profile_opt with Some profile -> profile | None -> MInstance.Profile.empty iid in

    let! () = 
      true_or (fail "Profil %s (%s) déjà créé par ses propriétaires" (IInstance.to_string iid) domain)
	(profile # unbound <> None)
    in

    let! () = ohm $ MInstance.Profile.Backdoor.update iid
      ~name:(json # name)
      ~key:(key,owid)
      ~pic:(BatOption.map IFile.decay (profile # pic))
      ~phone:(profile # phone)
      ~desc:(profile # desc)
      ~site:(profile # site)
      ~address:(json # address)
      ~contact:(profile # contact)
      ~facebook:(profile # facebook)
      ~twitter:(profile # twitter)
      ~tags:(json # tags)
      ~visible:true
      ~rss:[]
      ~owners:(json # owners)
    in

    ok "Profil %s (%s) mis à jour" (IInstance.to_string iid) (json # url) 

end)
