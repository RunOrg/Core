(* © 2013 RunOrg *)

open Common
open Atom_common
module Build = Atom_build

type nature = string

let address = nature "Adress" 
  ~create:"Nouvelle adresse"
  "Adresse"

let topic = nature "Topic" 
  ~create:"Nouveau thème"
  "Thème"

let contact = nature "Contact"
  ~create:"Nouveau contact"
  "Contact"

let avatar = nature "Avatar"
  ~parents:[contact]
  "Membre"
