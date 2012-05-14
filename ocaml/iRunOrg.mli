(* © 2012 IRunOrg *)

module Order : sig 

  include Ohm.Id.PHANTOM
    
  module Assert : sig
    val edit : 'any id -> [`Edit] id      
  end
  
  module Deduce : sig
    val make_edit_token : [`Unsafe] ICurrentUser.id -> IInstance.t -> [`Edit] id -> string
    val from_edit_token : [`Unsafe] ICurrentUser.id -> IInstance.t ->    'any id -> string -> [`Edit] id option 
  end

end

module Client : sig

  include Ohm.Id.PHANTOM
    
  module Assert : sig
  end
  
  module Deduce : sig
  end

end

module Offer : sig

  include Ohm.Id.PHANTOM
    
  module Assert : sig
    val main   : 'any id -> [`Main] id
    val memory : 'any id -> [`Memory] id
  end
  
  module Deduce : sig    
  end

end
