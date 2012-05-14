(* © 2012 RunOrg *)

open Ohm

module Fields = 
struct 

  type config = unit
  let  config = ()

  include Fmt.Make(struct
    type json t = [ `Firstname | `Lastname | `Login | `Pass | `Pass2 | `Accept ]
  end)
    
  let fields  = [ `Firstname ; `Lastname ; `Login ; `Pass ; `Pass2 ; `Accept ]
    
  let details = function
    | `Firstname -> Form.text     ~name:"firstname" ~label:"login.signup-form.firstname"
    | `Lastname  -> Form.text     ~name:"lastname"  ~label:"login.signup-form.lastname"
    | `Login     -> Form.text     ~name:"login"     ~label:"login.signup-form.login"
    | `Pass      -> Form.password ~name:"pass"      ~label:"login.signup-form.pass"
    | `Pass2     -> Form.password ~name:"pass2"     ~label:"login.signup-form.pass2"
    | `Accept    -> Form.checkbox ~name:"accept"    ~label:""
      
  let hash = Form.prefixed_name_as_hash "signup" details
    
end
    
module Form = Form.Make(Fields)
