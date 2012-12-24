(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.add_instance_admin

  module Format = Fmt.Make(struct
    type json t = < url : string ; email : string >
  end)

  let example = (object
    method url   = "nous.runorg.com"
    method email = "vnicollet@runorg.com"
  end)
    
  let action cuid json =

    let  email = json # email in
    let! uid = ohm_req_or (fail "Utilisateur inconnu: '%s'" email) $ MUser.by_email email in 

    let  domain = json # url in 
    let  okey, owid = ConfigWhite.slice_domain domain in
    let! key = req_or (fail "Domaine inconnu: '%s'" domain) okey in
    let! iid = ohm_req_or (fail "Domaine inconnu: '%s'" domain) $ MInstance.by_key (key,owid) in

    let! aid = ohm $ MAvatar.become_contact iid uid in 

    let! ruid = ohm_req_or (fail "Utilisateur RUNORG introuvable") $ MUser.by_email "contact@runorg.com" in 
    let! raid = ohm $ MAvatar.become_contact iid ruid in
    let  raid = IAvatar.Assert.is_self raid in
    let! from = ohm_req_or (fail "Avatar RUNORG introuvable") $ MAvatar.actor raid in  

    let namer = MPreConfigNamer.load iid in     
    let! gid  = ohm $ MPreConfigNamer.group "admin" namer in
    let  gid  = IGroup.Assert.admin gid in 

    let! () = ohm $ MMembership.admin ~from gid aid [ `Accept true ; `Default true ] in
    ok "Admin status granted"

end)
