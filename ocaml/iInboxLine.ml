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
	   | `HasFiles
	   | `HasPics
	   | `Events 
	   | `Groups 
	   | `Group of IGroup.t ]

  let of_string = function
    | "" 
    | "a"  -> `All
    | "e"  -> `Events
    | "hf" -> `HasFiles
    | "hp" -> `HasPics
    | "g"  -> `Groups 
    | s when s.[0] = 'g' -> `Group (IGroup.of_string (BatString.lchop s))
    |  _ -> `All 

  let to_string = function
    | `All       -> "a"
    | `HasFiles  -> "hf"
    | `HasPics   -> "hp"
    | `Events    -> "e"
    | `Groups    -> "g"
    | `Group eid -> "g" ^ IGroup.to_string eid  

  include Fmt.Make(struct
    type t = f
    let t_of_json = function 
      | Json.String s -> of_string s
      | _             -> `All
    let json_of_t t = 
      Json.String (to_string t)
  end)

  let seg = to_string, of_string

  let smallest = `All
  let largest  = `HasPics

end
