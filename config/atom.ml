(* © 2013 RunOrg *)

open Common
open Atom_common
module Build = Atom_build

type nature = string

let address = nature "Adress" 
  ~create:"Nouvelle adresse"
  
let topic = nature "Topic" 
  ~create:"Nouveau thème"
