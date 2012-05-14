(* © 2012 RunOrg *)

open Ohm
open BatPervasives

module Field = Fmt.Make(struct

(*
  let edit = JoyA.obj [
    JoyA.field "label" ~label:"Etiquette" (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) ;
    JoyA.field "explain" ~label:"Explication" (JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.i18n ())) ;
    JoyA.field "edit"  ~label:"Type" (JoyA.variant [
      JoyA.alternative ~label:"Texte long" "textarea" ;
      JoyA.alternative ~label:"Date" "date" ;
      JoyA.alternative ~label:"Texte moyen" "longtext" ;
      JoyA.alternative ~label:"Invisible" "hidden" ;
      JoyA.alternative ~label:"Photo" "picture" 
    ]) ;
    JoyA.field "valid" ~label:"Règles de validation" (JoyA.array (JoyA.variant [
      JoyA.alternative ~label:"Obligatoire" "required" ;
    ])) ;
    JoyA.field "mean"  ~label:"Sémantique" (JoyA.optional (JoyA.variant [
      JoyA.alternative ~label:"Prélude Page Info" "description" ;
      JoyA.alternative ~label:"Date" "date" ;
      JoyA.alternative ~label:"Date de Fin" "enddate" ;
      JoyA.alternative ~label:"Lieu" "location" ;
      JoyA.alternative ~label:"Photo" "picture" ;
      JoyA.alternative ~label:"Description Listes" "summary"
    ])) ;
  ]
*)

  type json t = <
    label   : string ;    
   ?explain : string option ; 
    edit    : [ `textarea | `date | `longtext | `hide | `picture ] ;
    valid   : [ `required | `max of int ] list ;
    mean    : [ `description | `date | `enddate | `location | `picture | `summary ] option 
  >

end)

include Fmt.Make(struct
  type json t = (string * Field.t) list
end)

let default = []

module Diff = Fmt.Make(struct

(*
  let edit = JoyA.variant [
    "Remove" |> JoyA.alternative
	~label:"Supprimer"
	~content:(JoyA.label "Champ" (JoyA.string ~autocomplete:MPreConfigNames.entity_field ())) ;
    "Move" |> JoyA.alternative
	~label:"Déplacer"
	~content:(JoyA.tuple [
	  "Champ", JoyA.string ~autocomplete:MPreConfigNames.entity_field () ;
	  "Après", JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.entity_field ())
	]) ;
    "Add" |> JoyA.alternative
	~label:"Ajouter/Modifier"
	~content:(JoyA.tuple [
	  "Champ", JoyA.string ~autocomplete:MPreConfigNames.entity_field () ;
	  "Propriétés", Field.edit
	])
  ]
*)

  type json t = 
    [ `Remove of string
    | `Move of string * string option 
    | `Add of string * Field.t 
    ]
end)

let names = function
  | `Add  (n,f) -> [ MPreConfigNames.entity_field, n ;
		     MPreConfigNames.i18n, f # label ]
  | _ -> []

let apply fields = function
  | `Remove f -> ListAssoc.unset f fields
  | `Move (f,after) -> ListAssoc.move ?after f fields
  | `Add (f,field) -> ListAssoc.replace f field fields

let apply_diff fields diffs = 
  List.fold_left apply fields diffs
