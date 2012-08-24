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
	[ `pickOne  of string list
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
      try Old.of_json json with _ -> raise exn

end)

module Simple = Fmt.Make(struct

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

type 'a field = <
  name     : 'a ;
  label    : TextOrAdlib.t ;
  edit     : FieldType.t ;
  required : bool  
>

type profile = 
  [ `Birthdate
  | `Phone    
  | `Cellphone
  | `Address  
  | `Zipcode  
  | `City     
  | `Country  
  | `Gender   
  ]

module Field = Fmt.Make(struct

  type json t = 
    [ `Local "l" of Simple.t 
    | `Profile "p" of bool * [ `Birthdate "b"
			     | `Phone     "p"
			     | `Cellphone "c"
			     | `Address   "a" 
			     | `Zipcode   "z"
			     | `City      "y"
			     | `Country   "n"
			     | `Gender    "g" ]
    | `Import "i" of bool * IGroup.t * string
    ]

  let t_of_json json = 
    try t_of_json json with exn ->
      match Simple.of_json_safe json with None -> raise exn | Some field ->
	`Local field

end)

module Flat = struct

  type t = 
    [ `Group   of (IGroup.t * string) field
    | `Profile of profile field
    ]

  let group req gid field = `Group (object
    method name = gid, field # name
    method edit = field # edit
    method required = req && field # required
    method label = field # label
  end)

  let profile req profile = `Profile (object
    method name = profile
    method required = req
    method edit = match profile with 
      | `Birthdate 
      | `Phone
      | `Cellphone
      | `Zipcode
      | `City 
      | `Country -> `LongText
      | `Address -> `Textarea
      | `Gender -> `PickOne [ `label `Gender_Male ; `label `Gender_Female ]
    method label = (`label profile :> TextOrAdlib.t)
  end)

  let collapse = function 
    | `Group g -> (object
      method name = ()
      method edit = g # edit
      method required = g # required
      method label = g # label
    end)
    | `Profile p -> (object
      method name = ()
      method edit = p # edit
      method required = p # required
      method label = p # label 
    end)

  let dispatch data = 
    let profile, groups = 
      List.fold_left begin fun (profile,groups) (key,json) ->
	match key with 
	  | `Group (gid,name) ->
	    let current = try BatPMap.find gid groups with Not_found -> [] in
	    profile, BatPMap.add gid ((name,json) :: current) groups
	  | `Profile key -> 
	    (key,json) :: profile, groups
      end ([],BatPMap.empty) data 
    in
    let groups = BatPMap.foldi (fun k l acc -> (k,l) :: acc) groups [] in
    (object
      method profile = profile
      method groups  = groups
     end)

end


