(* © 2012 RunOrg *)

open Ohm
open BatPervasives

module FieldType = Fmt.Make(struct   
    
  type json t = 
    [ `Textarea
    | `Date
    | `LongText
    | `Checkbox
    | `PickOne  of TextOrAdlib.t list
    | `PickMany of TextOrAdlib.t list
    ]

  (* Reverse compatibility with previous format *)

  module Old = Fmt.Make(struct

    type json t = 
      [ `Textarea "textarea" 
      | `Date "date"
      | `LongText "longtext"
      | `Checkbox "checkbox"
      | `PickOne  "pickOne"  of TextOrAdlib.t list
      | `PickMany "pickMany" of TextOrAdlib.t list 
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
	  | `pickOne  l -> `PickOne  (List.map (fun t -> `text t) l)
	  | `pickMany l -> `PickMany (List.map (fun t -> `text t) l)
	with _ -> raise exn
  end) 

  let t_of_json json = 
    try t_of_json json with exn ->
      try Old.of_json json  with _ -> raise exn

end)

module Field = Fmt.Make(struct

  module Old = Fmt.Make(struct
    type json t = <
      name  : string ;
      label : TextOrAdlib.t ;
      edit  : FieldType.t ;
      valid : [ `required | `max of int ] list 
    > 
  end)

  type json t = <
    name  : string ;
    label : TextOrAdlib.t ;
    edit  : FieldType.t ;
    required "req" : bool 
  > ;;
  
  let t_of_json json = 
    try t_of_json json with exn -> 
      match Old.of_json_safe json with None -> raise exn | Some obj -> 
	(object
	  method name = obj # name
	  method label = obj # label 
	  method edit = obj # edit 
	  method required = List.mem `required (obj # valid) 
	 end)
end)

include Fmt.Make(struct
  type json t = (string * Field.t) list
end)

let default = []


