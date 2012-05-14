(* © 2012 RunOrg *)

open Ohm

module Fields = 
struct
  
  type config = unit
  let  config = ()

  include Fmt.Make(struct
    type json t = [ `Pass | `Pass2 ]
  end)
    
  let fields  = [ `Pass ; `Pass2 ]
    
  let details = function
    | `Pass      -> Form.password ~name:"pass"      ~label:"login.signup-form.pass"
    | `Pass2     -> Form.password ~name:"pass2"     ~label:"login.signup-form.pass2"
      
  let hash = Form.prefixed_name_as_hash "confirm" details
    
end
  
module Form = Form.Make(Fields)

let trigger = "success"
