(* © 2012 RunOrg *)

module Room : sig 

  include Ohm.Id.PHANTOM
    
  module Assert : sig
    val created : 'any id -> [`Created] id
    val view    : 'any id -> [`View] id
    val post    : 'any id -> [`Post] id
    val bot     : 'any id -> [`Bot] id
  end
  
  module Deduce : sig
    val post    : [<`Created|`Post] id -> [`Post] id
    val make_post_token : [`Unsafe] ICurrentUser.id -> [`Post] id -> string
    val from_post_token : [`Unsafe] ICurrentUser.id -> 'any id    -> string -> [`Post] id option
    val make_view_token : [`Unsafe] ICurrentUser.id -> [`View] id -> string
    val from_view_token : [`Unsafe] ICurrentUser.id -> 'any id    -> string -> [`View] id option
  end

end

module Line : sig

  include Ohm.Id.PHANTOM
    
  module Assert : sig
  end
  
  module Deduce : sig
  end

end
