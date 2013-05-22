(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

(* Our "Delegates" used to be MAccess values. Not all of them have been converted yet, 
   so keep this type around just in case we have to read very old values. *)

module ReverseCompatibility = struct 

  module State = Fmt.Make(struct
    type json t = 
      [ `Pending   "p"
      | `Validated "v"
      | `Any       "a"
      ]
  end)

  include Fmt.Make(struct
    type json t = 
      [ `Nobody  "n"                           
      | `Admin   "o"                       
      | `Token   "m"                       
      | `Contact "c"                          
      | `TokOnly "t" of t
      | `List    "l" of IAvatar.t list    
      | `Groups  "g" of State.t * (IAvatarSet.t list)
      | `Union   "u" of t list       
      ]
	
    (* Reverse-compatibility with non-polymorphic variants MAccess.Group and MAccess.Entity *)
    let t_of_json = function 
      | Json_type.Array [ kind ; first ; second ] ->
	t_of_json (Json_type.Array [ kind ; Json_type.Array [ first ; second ]])
      | other -> t_of_json other

  end)      
end

(* This type should be built only through 'make' to ensure data is in canonical form
   (thus allowing, for instance, equality comparisons). *)

type specific = { 
  avatars : IAvatar.t list ;
  groups  : IAvatarSet.t list 
}

let make ~avatars ~groups = 
  if avatars = [] && groups = [] then `Admin else
    `Specific {
      avatars = BatList.sort_unique compare avatars ;
      groups  = BatList.sort_unique compare groups
    }

let union a b = 
  match a, b with 
    | `Admin, other | other, `Admin -> other 
    | `Everyone, _ | _, `Everyone -> `Everyone
    | `Specific a, `Specific b -> make ~avatars:(a.avatars @ b.avatars) ~groups:(a.groups @ b.groups) 

include Fmt.Make(struct

  type t = 
    [ `Admin
    | `Everyone
    | `Specific of specific ]

  let json_of_t = function 
    | `Admin -> Json.Bool false
    | `Everyone -> Json.Bool true
    | `Specific s -> Json.Object begin
      let l = if s.avatars = [] then [] else [ "a", Json.of_list IAvatar.to_json s.avatars] in
      if s.groups = [] then l else ( "g", Json.of_list IAvatarSet.to_json s.groups) :: l       
    end

  let t_of_json = function 
    | Json.Bool everyone -> if everyone then `Everyone else `Admin
    | Json.Object l -> 
      let avatars, groups = List.fold_left begin fun (a,g) (k,v) ->
	match k with 
	| "a" -> (Json.to_list IAvatar.of_json v, g)
	| "g" -> (a, Json.to_list IAvatarSet.of_json v)
	|  _  -> (a,g)
      end ([],[]) l in
      make ~avatars ~groups

    (* Any other kind of JSON might possibly be a MAccess-formatted value. *)
    | other -> let result = ReverseCompatibility.of_json other in 
	       let rec recover = function 
		 | `Nobody 
		 | `Admin -> `Admin
		 | `Token 
		 | `Contact -> `Everyone
		 | `TokOnly sub -> recover sub 
		 | `List avatars -> make ~avatars ~groups:[]
		 | `Groups (`Validated,groups) -> make ~avatars:[] ~groups
		 | `Groups (_,_) -> `Everyone (* A bit hackish, but there should be no such values. *)
		 | `Union l -> List.fold_left union `Admin (List.map recover l) 
	       in
	       recover result
end)

let set_avatars avatars = function 
  | `Admin      -> make ~avatars ~groups:[]
  | `Everyone   -> `Everyone
  | `Specific s -> make ~avatars ~groups:s.groups 

let avatars = function
  | `Everyone 
  | `Admin      -> []
  | `Specific s -> s.avatars
