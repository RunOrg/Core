(* © 2012 IRunOrg *)

open Ohm
open BatPervasives

module Order = struct

  include Id.Phantom

  module Assert = struct 
    let edit = identity
  end
    
  module Deduce = struct

    let make_edit_token user instance order = 
      ICurrentUser.prove "edit_order" user [IInstance.to_string instance ; Id.str order]
	
    let from_edit_token user instance order proof =
      if ICurrentUser.is_proof proof "edit_order" user [IInstance.to_string instance ; Id.str order] 
      then Some order else None

  end

end

module Client = struct

  include Id.Phantom

  module Assert = struct 
  end
  
  module Deduce = struct
  end

end

module Offer = struct

  include Id.Phantom

  module Assert = struct 
    let main   = identity
    let memory = identity
  end
  
  module Deduce = struct
  end

end
