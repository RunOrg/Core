(* © 2013 RunOrg *)

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
      owners : (string * string * string) list ;
      visible : bool ;
    >
  end)

  let example = (object
    method name = "Football Club Paris XXe"
    method url  = "fc75020.runorg.com"
    method address = Some "22 rue Planchat, 75020 Paris"
    method tags = [ "football" ; "sport" ; "club" ; "paris" ]
    method owners = [ 
      "Victor", "Nicollet", "vnicollet@runorg.com" ; 
      "Mehdi",  "Foughali", "mfoughali@runorg.com" ;
    ]
    method visible = true
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

    let! owners = ohm $ Run.list_map begin fun (firstname,lastname,email) ->

      let data = object
	method firstname = firstname
	method lastname  = lastname
	method password  = None
	method email     = email 
	method white     = owid 
      end in 

      let! result = ohm $ MUser.quick_create data in 

      match result with 
	| `duplicate uid -> return uid 
	| `created cuid -> return (IUser.Deduce.is_anyone cuid) 

    end (json # owners) in

    let owners = BatList.sort_unique compare owners in 

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
      ~visible:(json # visible) 
      ~owners
    in

    ok "Profil %s (%s) mis à jour" (IInstance.to_string iid) (json # url) 

end)
