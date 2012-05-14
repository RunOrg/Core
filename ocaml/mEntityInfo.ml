(* © 2012 MRunOrg *)

open Ohm
open BatPervasives

module Format = JoyA.Make(struct

  let edit = JoyA.variant [
    JoyA.alternative ~label:"Texte court" "t" ;
    JoyA.alternative ~label:"Texte long" "lt" ;
    JoyA.alternative ~label:"Date" "d" ;
    JoyA.alternative ~label:"Lieu" "l" ;
    JoyA.alternative ~label:"Lien" "u"
  ]

  type json t = 
    [ `text     "t"
    | `longtext "lt"
    | `date     "d"
    | `location "l"
    | `link     "u"
    ]

end)

module Data = Fmt.Make(struct
  type json t = (string * <
    section "s" : string ;
    items   "i" : (string * <
     ?label  "l" : string option ;
      fields "f" : (string * <
	field  "n" : string ;
        format "f" : Format.t
      >) list
    >) list
  >) list


  module Previous = Fmt.Make(struct
    type json t = (string * <
      section "s" : string ;
      items   "i" : (string * <
       ?label  "l" : string option ;
        fields "f" : (string * <
          field  "n" : string ;
	  format "f" : Format.t
        >) assoc   
      >) assoc
    >) assoc
  end)

  let t_of_json json = 
    try t_of_json json 
    with exn -> 
      try Previous.of_json json
      with _ -> raise exn

end)

include Data

let default = []

module Diff = JoyA.Make(struct

  let edit = JoyA.variant [
    "AddField" |> JoyA.alternative
	~label:"Champ : Ajouter"
	~content:(JoyA.tuple [
	  "Section",   JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Ligne",     JoyA.string ~autocomplete:MPreConfigNames.info_line () ;
	  "Champ",     JoyA.string ~autocomplete:MPreConfigNames.info_field () ;
	  "Source",    JoyA.string ~autocomplete:MPreConfigNames.entity_field () ;
	  "Format",    Format.edit
	]) ;
    "MovField" |> JoyA.alternative
	~label:"Champ : Déplacer"
	~content:(JoyA.tuple [
	  "Section", JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Ligne",   JoyA.string ~autocomplete:MPreConfigNames.info_line () ;
	  "Champ",   JoyA.string ~autocomplete:MPreConfigNames.info_field () ;
	  "Après",   JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.info_field ())
	]) ;
    "DelField" |> JoyA.alternative
	~label:"Champ : Supprimer"
	~content:(JoyA.tuple [
	  "Section", JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Ligne",   JoyA.string ~autocomplete:MPreConfigNames.info_line () ;
	  "Champ",   JoyA.string ~autocomplete:MPreConfigNames.info_field ()
	]) ;
    "AddItem" |> JoyA.alternative
	~label:"Ligne : Ajouter"
	~content:(JoyA.tuple [
	  "Section",   JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Ligne",     JoyA.string ~autocomplete:MPreConfigNames.info_line () ;
	  "Etiquette", JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.i18n ())
	]) ;
    "MovItem" |> JoyA.alternative
	~label:"Ligne : Déplacer"
	~content:(JoyA.tuple [
	  "Section", JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Ligne",   JoyA.string ~autocomplete:MPreConfigNames.info_line () ;
	  "Après",   JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.info_line ())
	]) ;
    "DelItem" |> JoyA.alternative
	~label:"Ligne : Supprimer"
	~content:(JoyA.tuple [
	  "Section", JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Ligne",   JoyA.string ~autocomplete:MPreConfigNames.info_line ()
	]) ;
    "AddSection" |> JoyA.alternative
	~label:"Section : Ajouter"
	~content:(JoyA.tuple [
	  "Section",   JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Etiquette", JoyA.string ~autocomplete:MPreConfigNames.i18n ()
	]) ;
    "MovSection" |> JoyA.alternative 
	~label:"Section : Déplacer"
	~content:(JoyA.tuple [
	  "Section", JoyA.string ~autocomplete:MPreConfigNames.info_section () ;
	  "Après",   JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.info_section ())
	]) ;
    "DelSection" |> JoyA.alternative
	~label:"Section : Supprimer"
	~content:(JoyA.label "Section" (JoyA.string ~autocomplete:MPreConfigNames.info_section ())) ;
  ]

  type json t = 
    [ `DelSection of string
    | `DelItem    of string * string
    | `DelField   of string * string * string
    | `AddSection of string * string
    | `AddItem    of string * string * string option
    | `AddField   of string * string * string * string * Format.t
    | `MovSection of string * string option
    | `MovItem    of string * string * string option
    | `MovField   of string * string * string * string option
    ]

end)

let names = function
  | `AddSection (s,l) -> [ MPreConfigNames.info_section, s ]
  | `AddItem (s,i,l) -> [ MPreConfigNames.info_line, i ] 
    @ (match l with None -> [] | Some l -> [MPreConfigNames.i18n, l])
  | `AddField (s,i,f,src,_) -> [ MPreConfigNames.info_field, f ]
  | _ -> []

let map_section f s = object
  method section = s # section
  method items   = f (s # items)
end

let map_item f i = object
  method label  = i # label
  method fields = f (i # fields)
end

let apply data = function
  | `DelSection s -> ListAssoc.unset s data
  | `DelItem (s,i) -> ListAssoc.map s (map_section (ListAssoc.unset i)) data
  | `DelField (s,i,f) ->
    ListAssoc.map s
      (map_section (ListAssoc.map i
	  (map_item (ListAssoc.unset f)))) data
  | `AddSection (s,sn) ->
    ListAssoc.replace s
      (object
	method section = sn
	method items   = []
       end) data
  | `AddItem (s,i,il) ->
    ListAssoc.map s
      (map_section (ListAssoc.replace i
	 (object 
	   method label = il
	   method fields = []
	  end))) data
  | `AddField (s,i,f,fn,ff) ->
    ListAssoc.map s
      (map_section (ListAssoc.map i
	 (map_item (ListAssoc.replace f
	    (object
	      method field = fn
	      method format = ff
	     end))))) data
  | `MovSection (s,after) -> ListAssoc.move ?after s data
  | `MovItem (s,i,after) -> ListAssoc.map s (map_section (ListAssoc.move ?after i)) data
  | `MovField (s,i,f,after) ->
    ListAssoc.map s
      (map_section (ListAssoc.map i
	  (map_item (ListAssoc.move ?after f)))) data

let apply_diff data diffs = 
  List.fold_left apply data diffs
