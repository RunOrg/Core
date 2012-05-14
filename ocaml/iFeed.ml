(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom

module Access = struct

  type t =  
    [ `Read  of [`Read]  id
    | `Write of [`Write] id
    | `Admin of [`Admin] id ] 

  type opt = t option

  let read = function
    | Some (`Read  id) -> Some id
    | Some (`Write id) -> Some id
    | Some (`Admin id) -> Some id
    | _ -> None

  let write = function
    | Some (`Write id) -> Some id
    | Some (`Admin id) -> Some id
    | _ -> None

  let admin = function
    | Some (`Admin id) -> Some id
    | _ -> None

end
  
module Assert = struct 
  let admin id = id
  let write id = id
  let read  id = id
  let bot   id = id
end

module Deduce = struct
  let can_write id = id
  let can_read  id = id
    
  let make_write_token user feed react = 
    ICurrentUser.prove "feed_write" user [ Id.str feed ; if react then "react" else "" ]
      
  let from_write_token user feed react proof =
    if ICurrentUser.is_proof proof "feed_write" user [ Id.str feed ; if react then "react" else "" ] 
    then Some feed else None
      
  let make_read_token user feed react = 
    ICurrentUser.prove "feed_read" user [ Id.str feed ; if react then "react" else ""]
      
  let from_read_token user feed react proof =
    if ICurrentUser.is_proof proof "feed_read" user [ Id.str feed ; if react then "react" else ""] 
    then Some feed else None
      
end

