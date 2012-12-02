(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let endpoints = ref []
let declare label path = 
  let endpoint, define = O.declare O.secure ("admin/api/" ^ path) A.none in
  endpoints := (label,endpoint) :: !endpoints ;
  define

let all_endpoints server = 
  List.map (fun (label,endpoint) -> (object
    method label = label
    method url = Action.url endpoint server ()
  end)) !endpoints

let add_instance_admin = declare "Ajouter un Administrateur à un Espace" "add-instance-admin"

let edit_instance_profile = declare "Modifier un Profil d'Association" "edit-instance-profile"

let reboot = declare "Redémarrer le Serveur" "reboot"

let rename_instance = declare "Changer l'URL d'une Association" "rename-instance"

let confirm_user = declare "Confirmer un compte utilisateur" "confirm-user"
