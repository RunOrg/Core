(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

module Profile = struct
    
  module Fields = struct
      
    module What = Fmt.Make(struct
      type json t = [ (* `Nothing |*) `Basic | `Default | `Everything ] 
    end)
            
    type config = unit 
    let  config = ()

    include Fmt.Make(struct	
      type json t = [ `What ] 
    end)
      
    let fields  = [ `What ]
      
    let details = function
    
      | `What   ->
	Form.radio ~name:"what" ~label:"profile.share.what"
	  ~values:(fun () -> [ (* `Nothing ; *) `Basic ; `Default ; `Everything])
	  ~renderer:(fun t -> What.to_json t ,
	    match t with 
          (*  | `Nothing    -> `label "profile.share.what.nothing" *)
	      | `Basic      -> `label "profile.share.what.basic"
	      | `Default    -> `label "profile.share.what.default"
	      | `Everything -> `label "profile.share.what.everything")

    let hash = Form.prefixed_name_as_hash "share-profile" details
      
  end
    
  module Form = Form.Make(Fields)

end

module Config = struct

  module Fields = struct

    type config = unit
    let  config = ()

    include Fmt.Make(struct
      type json t = [ `birth     "i"
  		    | `email     "e"
		    | `phone     "p"
		    | `cellphone "c"
		    | `address   "a"
		    | `city      "z" (* And zipcode *)
		    | `country   "n" 
		    | `gender    "g" ]
    end)

    let fields = [`birth;`email;`phone;`cellphone;`address;`city;`country;`gender]

    let details = fun item ->
      let name, label = match item with 
	| `birth     -> "birth",     "profile.share.config.birth"
	| `email     -> "email",     "profile.share.config.email"
	| `phone     -> "phone",     "profile.share.config.phone"
	| `cellphone -> "cellphone", "profile.share.config.cellphone"
	| `address   -> "address",   "profile.share.config.address"
	| `city      -> "city",      "profile.share.config.city"
	| `country   -> "country",   "profile.share.config.country"
	| `gender    -> "gender",    "profile.share.config.gender"
      in
      Form.checkbox ~name ~label 

    let hash = Form.prefixed_name_as_hash "share-config" details

  end

  module Form = Form.Make(Fields)

end
