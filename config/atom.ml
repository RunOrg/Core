(* © 2013 RunOrg *)

open Common
open Atom_common
module Build = Atom_build

type nature = string

let address = nature "Adress" "Adresse indisponible"
  ~create:"Nouvelle adresse"
  "Adresse"

let topic = nature "Topic" "Thème indisponible"
  ~create:"Nouveau thème"
  "Thème"

let contact = nature "Contact" "Contact indisponible"
  ~create:"Nouveau contact"
  "Contact"

let avatar = nature "Avatar" "Profil membre inaccessible"
  ~parents:[contact]
  "Membre"

let group = nature "Group" "Groupe secret"
  "Groupe"
