(* © 2012 RunOrg *)

open Ohm
open BatPervasives

module Room = struct

  include Id.Phantom

  module Assert = struct 
    let created = identity 
    let view    = identity
    let post    = identity
    let bot     = identity
  end
    
  module Deduce = struct
    let post    = identity

    let make_post_token user id = 
      ICurrentUser.prove "chat_post" user [ Id.str id ]
	
    let from_post_token user id proof =
      if ICurrentUser.is_proof proof "chat_post" user [ Id.str id ] 
      then Some id else None

    let make_view_token user id = 
      ICurrentUser.prove "chat_view" user [ Id.str id ]
	
    let from_view_token user id proof =
      if ICurrentUser.is_proof proof "chat_view" user [ Id.str id ] 
      then Some id else None

  end

end

module Line = struct

  include Id.Phantom

  module Assert = struct 
  end
  
  module Deduce = struct
  end

end
