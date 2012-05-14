(* © 2012 RunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let read  x = x
  let write x = x
  let admin x = x
end
  
module Deduce = struct
end

module Article = struct

  include Id.Phantom
    
  module Assert = struct 
  end
    
  module Deduce = struct
  end

end

module Page = struct

  include Id.Phantom
    
  module Assert = struct 
  end
    
  module Deduce = struct
  end

end

