(* © 2012 IRunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct 
  let answer      id = id
  let read        id = id
  let created     id = id
  let bot = identity
end
  
module Deduce = struct
    
  let created_can_read id = id
  let read_can_answer  id = id
  let answer_can_read  id = id
    
  let make_answer_token user poll = 
    ICurrentUser.prove "answer_poll" user [Id.str poll]
      
  let from_answer_token user poll proof =
    if ICurrentUser.is_proof proof "answer_poll" user [Id.str poll] 
    then Some poll else None
      
end

