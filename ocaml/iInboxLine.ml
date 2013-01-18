(* © 2012 RunOrg *)

open Ohm
open BatPervasives
  
include Id.Phantom

module Assert = struct 
end

module Deduce = struct
end

module View = struct
  type t = Id.t
  let of_id = identity
  let to_id = identity
  let make ilid aid = 
    Id.of_string (to_string ilid ^ "-" ^ IAvatar.to_string aid) 
end

module Filter = struct

  type f = [ `All
	   | `Events 
	   | `Groups 
	   | `Group of IEntity.t ]

  let of_string = function
    | "" 
    | "a" -> `All
    | "e" -> `Events
    | "g" -> `Groups 
    | s when s.[0] = 'g' -> `Group (IEntity.of_string (BatString.lchop s))
    |  _ -> `All 

  let to_string = function
    | `All       -> "a"
    | `Events    -> "e"
    | `Groups    -> "g"
    | `Group eid -> "g" ^ IEntity.to_string eid  

  include Fmt.Make(struct
    type t = f
    let t_of_json = function 
      | Json.String s -> of_string s
      | _             -> `All
    let json_of_t t = 
      Json.String (to_string t)
  end)

  let seg = to_string, of_string

end
