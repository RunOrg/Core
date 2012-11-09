(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct
  let exec = identity
end

module Deduce = struct

  let make_exec_token user payment = 
    ICurrentUser.prove "exec_payment" user [Id.str payment]
      
  let from_exec_token user payment proof =
    if ICurrentUser.is_proof proof "exec_payment" user [Id.str payment] then Some payment else None

end
