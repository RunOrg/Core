(* © 2013 RunOrg *)

open Common

type nature = { 
  n_name  : string ; 
  n_label_create : adlib option ;
  n_label_lim : adlib ;
  n_parents : string list ; 
  n_label : adlib ; 
}

let natures = ref []

let nature name lim ?(parents=[]) ?create label = 
  natures := {
    n_name = name ;
    n_label_create = BatOption.map (adlib ("Atom_Nature_" ^ name ^ "_Create")) create ;
    n_label_lim = adlib ("Atom_Nature_" ^ name ^ "_Limited") lim ; 
    n_parents = parents;
    n_label = adlib ("Atom_Nature_" ^ name) label ;
  } :: !natures ;
  name 
    

