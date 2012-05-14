(* © 2012 MRunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Eval = Fmt.Make(struct
  type json t = 
    [ `profile "u" of [ `firstname 
		      | `lastname 
		      | `email 
		      | `birthdate
		      | `phone
		      | `cellphone 
		      | `address
		      | `zipcode
		      | `city
		      | `country
		      | `gender 
		      ] 
    | `join "j" of int * [ `state
			 | `date 
			 | `field of string ]
    ]
end)
  
module View = Fmt.Make(struct

(*
  let edit = JoyA.variant [
    JoyA.alternative ~label:"Texte" "t" ;
    JoyA.alternative ~label:"Date"  "d" ;
    JoyA.alternative ~label:"Oui/Non" "c" ;
    JoyA.alternative ~label:"Date & Heure" "dt" ;
    JoyA.alternative ~label:"Statut" "s" ;
    JoyA.alternative ~label:"Age" "a" ;
    JoyA.alternative ~label:"Liste de choix" "po"
  ]
*)

  type json t = 
    [ `text "t"
    | `date "d"
    | `checkbox "c"
    | `datetime "dt"
    | `status "s"
    | `age  "a"
    | `pickAny "po"
    ]

end)
  
module DiffEval = Fmt.Make(struct
(*
  let edit = JoyA.variant [

    "profile" |> JoyA.alternative
	~label:"Champ du profil" 
	~content:(JoyA.variant [
	  JoyA.alternative ~label:"Prénom" "firstname" ;
	  JoyA.alternative ~label:"Nom" "lastname" ;
	  JoyA.alternative ~label:"Email" "email" ;
	  JoyA.alternative ~label:"Date de naissance" "birthdate" ;
	  JoyA.alternative ~label:"Téléphone" "phone" ;
	  JoyA.alternative ~label:"Portable" "cellphone" ;
	  JoyA.alternative ~label:"Adresse" "address" ;
	  JoyA.alternative ~label:"Code postal" "zipcode" ;
	  JoyA.alternative ~label:"Ville" "city" ;
	  JoyA.alternative ~label:"Pays" "country" ;
	  JoyA.alternative ~label:"Sexe" "gender" 
	]) ;

    "self" |> JoyA.alternative 
	~label:"Champ de cette entité"
	~content:(JoyA.variant [
	  JoyA.alternative ~label:"Statut" "state" ;
	  JoyA.alternative ~label:"Date" "date" ;
	  JoyA.alternative ~label:"Champ"
	    ~content:(JoyA.string ~autocomplete:MPreConfigNames.entity_field ()) "field"
	]) ;

    "named" |> JoyA.alternative
	~label:"Champ d'une autre entité"
	~content:(JoyA.tuple [
	  "Entité", JoyA.string ~autocomplete:MPreConfigNames.entity () ;
	  "Valeur", JoyA.variant [
	    JoyA.alternative ~label:"Statut" "state" ;
	    JoyA.alternative ~label:"Date" "date" ;
	    JoyA.alternative ~label:"Champ"
	      ~content:(JoyA.string ~autocomplete:MPreConfigNames.entity_field ()) "field"
	  ]
	]) 

  ]
*)

  type json t = 
    [ `profile of [ `firstname 
		  | `lastname 
		  | `email 
		  | `birthdate
		  | `phone
		  | `cellphone 
		  | `address
		  | `zipcode
		  | `city
		  | `country
		  | `gender 
		  ]
    | `self of  [ `state 
		| `date 
		| `field of string ]
    | `named of string * [ `state 
			 | `date 
			 | `field of string ]
    ]      

end)

module DiffColumn = Fmt.Make(struct

(*
  let edit = JoyA.obj [
    JoyA.field "after" ~label:"Insérer après ..." (JoyA.optional DiffEval.edit) ;
    JoyA.field "sort"  ~label:"Triable?" JoyA.bool ;
    JoyA.field "show"  ~label:"Visible?" JoyA.bool ;
    JoyA.field "eval"  ~label:"Source" DiffEval.edit ;
    JoyA.field "view"  ~label:"Affichage" View.edit ;
    JoyA.field "label" ~label:"Etiquette" (JoyA.string ~autocomplete:MPreConfigNames.i18n ())
  ]
*)  

  type json t =   <
    after : DiffEval.t option ;
    sort  : bool ;
    show  : bool ;
    eval  : DiffEval.t ;
    view  : View.t ;
    label : string 
  >

end)

module Diff = Fmt.Make(struct

(*
  let edit = JoyA.variant [
    "Add"     |> JoyA.alternative ~label:"Ajouter/déplacer une colonne" ~content:DiffColumn.edit ;
    "Remove"  |> JoyA.alternative ~label:"Supprimer une colonne" ~content:DiffEval.edit ;
    "Refresh" |> JoyA.alternative ~label:"Recalculer la grille" ;
  ]
*)

  type json t = 
    [ `Add of DiffColumn.t 
    | `Remove of DiffEval.t
    | `Refresh
    ]      

end)

let names = function
  | `Remove _ -> []
  | `Refresh  -> []
  | `Add c -> [ MPreConfigNames.i18n, c # label ]

