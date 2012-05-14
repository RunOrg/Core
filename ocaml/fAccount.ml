(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Password = struct

  module Fields = struct
      
    type config = unit
    let  config = ()
    
    include Fmt.Make(struct type json t = [ `Pass | `Pass2 ] end)
      
    let fields  = [ `Pass ; `Pass2 ]
      
    let details = function
      | `Pass      -> Form.password ~name:"pass"      ~label:"login.signup-form.pass"
      | `Pass2     -> Form.password ~name:"pass2"     ~label:"login.signup-form.pass2"
	
    let hash = Form.prefixed_name_as_hash "setpass" details
      
  end
    
  module Form = Form.Make(Fields)
    
end

module Edit = struct

  module Fields = struct
      
    type config = <
      uploader : Id.t -> string -> View.Context.box View.t ;
      gender   : Id.t -> string -> View.Context.box View.t ;
    > ;;

    let config  = (object 
      method uploader _ _ = View.esc "[Please use non-default config]" 
      method gender   _ _ = View.esc "[Please use non-default config]" 
    end)

    include Fmt.Make(struct
      type json t = [ `Firstname | `Lastname | `Birthdate | `Phone | `Pic 
                    | `Cellphone | `Address  | `Zipcode | `City | `Country | `Gender ]
    end)             
    
    let fields  = [ `Firstname ; `Lastname ; `Birthdate ; `Phone ; `Pic ;
		    `Cellphone ; `Address  ; `Zipcode ; `City ; `Country ; `Gender ]

    let details = function 
      | `Firstname -> Form.text     ~name:"firstname" ~label:"account.field.firstname"
      | `Lastname  -> Form.text     ~name:"lastname"  ~label:"account.field.lastname"
      | `Birthdate -> Form.text     ~name:"birthdate" ~label:"account.field.birthdate"
      |> Form.add_js (fun id i18n -> Js.datepicker (Id.sel id) ~lang:(I18n.language i18n) ~ancient:true)
      | `Phone     -> Form.text     ~name:"phone"     ~label:"account.field.phone"
      | `Cellphone -> Form.text     ~name:"cellphone" ~label:"account.field.cellphone"
      | `Address   -> Form.textarea ~name:"address"   ~label:"account.field.address"
      | `Zipcode   -> Form.text     ~name:"zipcode"   ~label:"account.field.zipcode"
      | `City      -> Form.text     ~name:"city"      ~label:"account.field.city"
      | `Country   -> Form.text     ~name:"country"   ~label:"account.field.country"
      | `Gender    -> Form.custom   ~name:"gender"    ~label:"account.field.gender" ~json:false
	~render:(fun (cfg:config) -> cfg # gender) 
      | `Pic       -> Form.custom   ~name:"pic"       ~label:"account.field.picture" ~json:false
	~render:(fun (cfg:config) -> cfg # uploader)

    let hash = Form.prefixed_name_as_hash "account-edit" details

  end

  module Form = Form.Make(Fields)

end
