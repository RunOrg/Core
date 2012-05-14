(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

module Create = struct

  module Fields = struct
      
    type config = unit
    let  config = ()

    include Fmt.Make(struct      
      type json t = [ `Title ]
    end)
      
    let fields  = [ `Title ]
      
    let details = function
      | `Title     -> Form.text ~name:"title"      ~label:"messages.create-form.title"
	
    let hash = Form.prefixed_name_as_hash "message-create" details
      
  end
    
  module Form = Form.Make(Fields)
    
end
