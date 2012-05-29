(* © 2012 MRunOrg *)

open Ohm
open BatPervasives

module FieldType = Fmt.Make(struct   

  type json t = 
    [ `textarea 
    | `date 
    | `longtext
    | `checkbox
    | `pickOne  of [`label "l" of string | `text "t" of string] list
    | `pickMany of [`label "l" of string | `text "t" of string] list 
    ]

  (* Reverse compatibility with previous format *)

  module Old = Fmt.Make(struct
    type json t = 
      [ `pickOne of string list
      | `pickMany of string list 
      ]
  end)

  let t_of_json json = 
    try t_of_json json with exn -> 
      try match Old.of_json json with 
	| `pickOne  l -> `pickOne  (List.map (fun t -> `text t) l)
	| `pickMany l -> `pickMany (List.map (fun t -> `text t) l)
      with _ -> raise exn

end)

module Field = Fmt.Make(struct
  type json t = <
    name  : string ;
    label : [ `label of string | `text of string ] ;
    edit  : FieldType.t ;
    valid : [ `required | `max of int ] list 
  > 
end)

module FieldDiff = Fmt.Make(struct
    
(*
  let edit = JoyA.obj [
    JoyA.field "name"  ~label:"Nom" (JoyA.string ~autocomplete:MPreConfigNames.join_field ()) ;
    JoyA.field "label" ~label:"Etiquette" (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) ;
    JoyA.field "edit"  ~label:"Type" (JoyA.variant [
      JoyA.alternative ~label:"Texte long" "textarea" ;
      JoyA.alternative ~label:"Date" "date" ;
      JoyA.alternative ~label:"Texte moyen" "longtext" ;
      JoyA.alternative ~label:"Case à cocher" "checkbox" ;
      JoyA.alternative ~label:"Choix simple" ~content:(	
	JoyA.array (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) 							
      ) "pickOne" ;
      JoyA.alternative ~label:"Choix multiple" ~content:(	
	JoyA.array (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) 							
      ) "pickMany" ;
    ]) ;
    JoyA.field "required" ~label:"Obligatoire" JoyA.bool ; 
  ]
*)

  type json t = <
    name : string ;
    label : string ;
    edit : [ `textarea
	   | `date 
	   | `longtext
	   | `checkbox
	   | `pickOne of string list
	   | `pickMany of string list
	   ] ;
    required : bool 
  > ;;

end)

let to_field (t : FieldDiff.t) = ( object
  method name = t # name
  method label = (`label t # label)
  method edit = match t # edit with
    | `textarea -> `textarea
    | `date     -> `date
    | `longtext -> `longtext
    | `checkbox -> `checkbox
    | `pickOne  l -> `pickOne  (List.map (fun t -> `label t) l)
    | `pickMany l -> `pickMany (List.map (fun t -> `label t) l)
  method valid = if t # required then [`required] else []
end : Field.t) 

include Fmt.Make(struct
  type json t = (string * Field.t) list
end)

let default = []

module Diff = Fmt.Make(struct

(*
  let edit = JoyA.variant [
    "Remove" |> JoyA.alternative
	~label:"Supprimer"
	~content:(JoyA.label "Champ" (JoyA.string ~autocomplete:MPreConfigNames.join_field ())) ;
    "Move" |> JoyA.alternative
	~label:"Déplacer"
	~content:(JoyA.tuple [
	  "Champ", JoyA.string ~autocomplete:MPreConfigNames.join_field () ;
	  "Après", JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.join_field ())
	]) ;
    "Add" |> JoyA.alternative
	~label:"Ajouter/Modifier"
	~content:FieldDiff.edit
  ]
*)

  type json t = 
    [ `Remove of string
    | `Move of string * string option 
    | `Add of FieldDiff.t 
    ]
end)

let names = function
  | `Add f -> [ MPreConfigNames.join_field, f # name ;
		MPreConfigNames.i18n, f # label ]
  | _ -> []

let apply fields = function
  | `Remove f -> ListAssoc.unset f fields
  | `Move (f,after) -> ListAssoc.move ?after f fields
  | `Add field -> ListAssoc.replace (field # name) (to_field field) fields

let apply_diff (fields : Field.t list) (diffs : Diff.t list) = 
  let assoc = List.map (fun f -> f # name, f) fields in 
  let assoc = List.fold_left apply assoc diffs in
  List.map snd assoc 

