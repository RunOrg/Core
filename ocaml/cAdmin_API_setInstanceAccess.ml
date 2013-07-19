(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_API_common

include Make(struct

  let api = UrlAdmin.API.set_instance_access

  module Format = Fmt.Make(struct
    type json t = <
      url : string ; 
      anyone_create_events : bool option ;
      anyone_search_atoms : bool option ; 
    >
  end)

  let example = (object
    method url  = "fc75020.runorg.com"
    method anyone_create_events = None
    method anyone_search_atoms = None
  end)
    
  let action cuid json =

    let  domain = json # url in 
    let  okey, owid = ConfigWhite.slice_domain domain in
    let! key = req_or (fail "Domaine inconnu: '%s'" domain) okey in

    let! iid_opt = ohm $ MInstance.Profile.Backdoor.by_key (key,owid) in
    let  iid = match iid_opt with Some iid -> iid | None -> IInstance.gen () in
    let  iid = IInstance.Assert.is_admin iid in 

    let! () = ohm (MInstanceAccess.update iid (fun d ->
      MInstanceAccess.Data.({
	events = (match json # anyone_create_events with 
	| None -> d.events
	| Some true -> `Everyone
	| Some false -> `Admin) ;
	search = (match json # anyone_search_atoms with
	| None -> d.search
	| Some true -> `Everyone
	| Some false -> `Admin) ;
      }))) 
    in
 
    ok "Droits de %s (%s) mis à jour" (IInstance.to_string iid) (json # url) 

end)
