(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload

type freq = [ `Immediate | `Daily | `Weekly | `Never ]

type assoc = (MNotifyChannel.t * freq) list
    
type t = <
  default : assoc ; 
  by_iid  : (IInstance.t * assoc) list 
> 

(* Define data types ---------------------------------------------------------------------------------------- *)

module Key = struct
  type t = [ `Default | `Instance of IInstance.t ]
  let to_string = function
    | `Default -> "def"
    | `Instance iid -> IInstance.to_string iid
  let of_string = function
    | "def" -> `Default
    | other -> `Instance (IInstance.of_string other)
end

module Data = Fmt.Make(struct
  type json t = 
      (!Key.t, 
       (MNotifyChannel.t * [ `Immediate "i"
			   | `Daily "d"
			   | `Weekly "w"
			   | `Never "n"]) list) ListAssoc.t
end)

let extract (list : (Key.t * assoc) list) = object
  val default = try List.assoc `Default list with _ -> []
  method default = default
  val by_iid = BatList.filter_map (fun (k,v) -> match k with 
    | `Default -> None
    | `Instance iid -> Some (iid,v)) list
  method by_iid = by_iid
end

let get _ = return $ extract []
let set _ _ = return ()
let send _ _ = return `Immediate
