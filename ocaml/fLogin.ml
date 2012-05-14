(* © 2012 RunOrg *)

open Ohm

module Fields = 
struct
  
  type config = unit
  let  config = ()

  include Fmt.Make(struct
    type json t = [ `Login | `Pass | `RememberMe ]
  end)
    
  let fields  = [ `Login ; `Pass ; `RememberMe ]
    
  let details = function
    | `Login      -> Form.text     ~name:"login"      ~label:"login.login-form.login"
    | `Pass       -> Form.password ~name:"pass"       ~label:"login.login-form.pass" 
    | `RememberMe -> Form.checkbox ~name:"rememberMe" ~label:"login.login-form.rememberMe"
      
  let hash = Form.prefixed_name_as_hash "login" details
    
end
  
module Form = Form.Make(Fields)

