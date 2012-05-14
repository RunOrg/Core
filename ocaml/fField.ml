(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

module Edit = struct
    
  module Fields = struct
      
    type config = unit
    let  config = () 

    include Fmt.Make(struct      
      type json t = [ `Label | `Old | `Required | `Choice of int ]
    end)
      
    let fields  = [ `Label ; `Old ]
      
    let details = function
      | `Label    -> Form.text     ~name:"label"    ~label:"field.label"
      | `Required -> Form.checkbox ~name:"required" ~label:"field.required"
      | `Old      -> Form.hidden   ~name:"old"      ~label:"" ~json:(fun _ -> true)
      | `Choice n -> 
	Form.text     
	  ~name:("choice-"^string_of_int n)
	  ~label:(if n = 0 then "field.choices" else "")
	
    let hash = Form.prefixed_name_as_hash "edit-field" details
      
  end
    
  module Form = Form.Make(Fields)

end



