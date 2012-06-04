(* © 2012 MRunOrg *)

open Ohm
open BatPervasives

module FieldType = Fmt.Make(struct   
    
  type json t = 
    [ `Textarea
    | `Date
    | `LongText
    | `Checkbox
    | `PickOne  of [ `label "l" of PreConfig_Adlibs.t | `text "t" of string ] list
    | `PickMany of [ `label "l" of PreConfig_Adlibs.t | `text "t" of string ] list
    ]

  (* Reverse compatibility with previous format *)

  module Old = Fmt.Make(struct

    type json t = 
      [ `Textarea "textarea" 
      | `Date "date"
      | `LongText "longtext"
      | `Checkbox "checkbox"
      | `PickOne  "pickOne"  of [`label "l" of string | `text "t" of string] list
      | `PickMany "pickMany" of [`label "l" of string | `text "t" of string] list 
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

  let t_of_json json = 
    try t_of_json json with exn ->
      let recover l = 
	List.map (function 
	  | `text t -> `text t
	  | `label l -> match PreConfig_Adlibs.recover l with 
	      | Some l -> `label l
	      | None -> `text l) l
      in 
      try match Old.of_json with 
	| `Textarea -> `Textarea
	| `Date     -> `Date
	| `LongText -> `LongText
	| `Checkbox -> `Checkbox
	| `PickOne  l -> `PickOne (recover l)
	| `PickMany l -> `PickMany (recover l)
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

include Fmt.Make(struct
  type json t = (string * Field.t) list
end)

let default = []


