(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct 
  let view = identity
end
  
module Deduce = struct

  let make_view_token user line = 
    ICurrentUser.prove "view_account_line" user [Id.str line]
      
  let from_view_token user line proof =
    if ICurrentUser.is_proof proof "view_account_line" user [Id.str line] then Some line else None

end
