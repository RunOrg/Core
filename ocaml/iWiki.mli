(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val read  : 'any id -> [`Read]  id
  val write : 'any id -> [`Write] id
  val admin : 'any id -> [`Admin] id 
end
  
module Deduce : sig
end

module Article : sig

  include Ohm.Id.PHANTOM
    
  module Assert : sig
  end
    
  module Deduce : sig
  end

end

module Page : sig
    
  include Ohm.Id.PHANTOM
    
  module Assert : sig
  end
    
  module Deduce : sig
  end

end
