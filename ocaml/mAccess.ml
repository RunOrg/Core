(* © 2012 RunOrg *)

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
      
module Signals = struct
  let in_group_call,  in_group  = Sig.make (Run.list_exists identity) 
  let of_entity_call, of_entity = Sig.make 
    (fun list -> let! list = ohm $ Run.list_map identity list in return (`Union list)) 
end

class type ['any] context = object 
  method self             : [`IsSelf] IAvatar.id 
  method isin             : 'any IIsIn.id 
end

let of_entity entity action = 
  Signals.of_entity_call (entity,action)     
    
let in_group aid gid status = 
  Signals.in_group_call (aid,gid,status)

let test (context : 'any #context) accesses = 

  let access     = optimize (`Union accesses) in
  
  let isin = context # isin in
  let aid  = IAvatar.decay (context # self) in

  let rec aux = function 
    | `Nobody        -> return false
    | `List       l  -> return (List.mem aid l)
    | `Groups  (s,l) -> Run.list_exists (fun g -> in_group aid g s) l
    | `Union      l  -> Run.list_exists aux l
    | `Admin         -> return (None <> IIsIn.Deduce.is_admin isin)
    | `Token         -> return (None <> IIsIn.Deduce.is_token isin)
    | `Contact       -> return true 
    | `TokOnly    t  -> if None = IIsIn.Deduce.is_token isin then return false else aux t
    | `Entity  (e,a) -> of_entity e a |> Run.bind aux
    | `Message    m  -> return false
  in
  
  aux access

let summary_reduce a b =
  if a = `Member then a else
    if b = `Member then b else
      `Admin
	    
let rec summarize = function
  | `Union   l -> List.fold_left summary_reduce `Admin $ List.map summarize l
  | `TokOnly t -> summarize t
  | `Token     -> `Member
  | _          -> `Admin

