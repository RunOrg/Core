(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Action = Fmt.Make(struct
  type json t = 
    [ `View   "v"
    | `Manage "m"
    ]
end) 

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
    | `Message "d" of IMessage.t
    | `List    "l" of IAvatar.t list    
    | `Groups  "g" of State.t * (IGroup.t list)
    | `Entity  "e" of IEntity.t * Action.t
    | `Union   "u" of t list       
    ]

  (* Reverse-compatibility with non-polymorphic variants MAccess.Group and MAccess.Entity *)
  let t_of_json = function 
    | Json_type.Array [ kind ; first ; second ] ->
      t_of_json (Json_type.Array [ kind ; Json_type.Array [ first ; second ]])
    | other -> t_of_json other

end)      

let optimize access = 
  let rec flatten = function
    | `Nobody        -> []
    | `Union       l -> List.flatten (List.map flatten l)
    | `List       [] -> []
    | `Groups (_,[]) -> []
    | any            -> [any]
  in
  match (List.sort compare (flatten access)) with 
    | []  -> `Nobody
    | [e] -> e
    | any -> `Union any
      
type of_entity  = IEntity.t -> Action.t -> t O.run
type in_group   = IAvatar.t -> IGroup.t -> State.t -> bool O.run
type in_message = IAvatar.t -> IMessage.t -> bool O.run

class type ['any] context = object
  method self_if_exists   : [`IsSelf] IAvatar.id option 
  method self             : [`IsSelf] IAvatar.id O.run
  method myself           : 'any IIsIn.id 
  method access_of_entity : of_entity 
  method avatar_in_group  : in_group
  method accesses_message : in_message
end

let test (context : 'any #context) accesses = 

  let access     = optimize (`Union accesses) in
  let of_entity  = context # access_of_entity in
  let in_group   = context # avatar_in_group  in
  let in_message = context # accesses_message in
  
  let isin = context # myself in 
  let aid_opt = BatOption.map IAvatar.decay (context # self_if_exists) in

  let rec aux = function 
    | `Nobody        -> return false
    | `List       l  -> ( match aid_opt with 
	| None     -> return false
	| Some aid -> return (List.mem aid l))
    | `Groups  (s,l) -> ( match aid_opt with 
	| None     -> return false
	| Some aid -> Run.list_exists (fun g -> in_group aid g s) l) 
    | `Union      l  -> Run.list_exists aux l
    | `Admin         -> return (None <> IIsIn.Deduce.is_admin isin)
    | `Token         -> return (None <> IIsIn.Deduce.is_token isin)
    | `Contact       -> return true 
    | `TokOnly    t  -> if None = IIsIn.Deduce.is_token isin then return false else aux t
    | `Entity  (e,a) -> of_entity e a |> Run.bind aux
    | `Message    m  -> ( match aid_opt with 
	| None     -> return false
	| Some aid -> in_message aid m )
  in
  
  aux access

let summary_reduce a b =
  if a = `Public then a else
    if b = `Public then b else
      if a = `Normal then a else
	if b = `Normal then b else
	  `Admin

let summary_invite_reduce a b = 
  if a = `Public then a else
    if b = `Public then b else
      if a = `Normal then a else
	if b = `Normal then b else
	  if a = `Invite then a else
	    if b = `Invite then b else
	      if a = `Registered then a else
		if b = `Registered then b else
		  `Admin
	    
let rec summarize = function
  | `Union   l -> List.fold_left summary_reduce `Admin $ List.map summarize l
  | `TokOnly t -> let sub = summarize t in 
		  if sub = `Public then `Normal else sub
  | `Token     -> `Normal
  | `Contact   -> `Public
  | _          -> `Admin

