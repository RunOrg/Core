(* © 2013 RunOrg *)

open Common

type nature = { 
  n_name  : string ; 
  n_label_create : adlib ;
}

let natures = ref []

let nature name ~create = 
  natures := {
    n_name = name ;
    n_label_create = adlib ("Atom_Nature_" ^ name ^ "_Create") create
  } :: !natures ;
  name 


