(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Import = struct

  module Fields = struct
      
    type config = unit
    let  config = ()

    include Fmt.Make(struct
      type json t = [`List|`Action]
    end)

    let fields = [`List;`Action]

    let details = function
      | `List -> Form.textarea ~name:"list" ~label:""
      | `Action -> Form.radio ~name:"action" ~label:""
	~values:(fun _ -> [`invite;`add])
	~renderer:(fun t -> MJoinCreateState.to_json (t :> MJoinCreateState.t),
	  match t with 
	    | `invite -> `label "member.add-or-invite.invite"
	    | `add    -> `label "member.add-or-invite.add")

    let hash = Form.prefixed_name_as_hash "member-import" details

  end

  module Form = Form.Make(Fields)

end

module Select = struct

  module Fields = struct
      
    type config = <
      picker : Id.t -> string -> View.Context.box View.t ;
    > ;;

    let config = (object
      method picker _ _ = View.esc "[Please use non-default config]"
    end)

    include Fmt.Make(struct
      type json t = [ `Pick ]
    end)

    let fields  = [ `Pick ]

    let details = function
      | `Pick -> Form.custom ~name:"picker" ~label:"" ~json:true
	~render:(fun (cfg:config) -> cfg # picker)

    let hash = Form.prefixed_name_as_hash "member-select" details

  end

  module Form = Form.Make(Fields)

end

module Create = struct

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
      type json t = [ `Firstname | `Lastname | `Email | `Birthdate | `Phone | `Pic 
  		    | `Cellphone | `Address  | `Zipcode | `City | `Country | `Gender ]
    end)

    let fields  = [ `Firstname ; `Lastname ; `Email ; `Birthdate ; `Phone ; `Pic ;
		    `Cellphone ; `Address  ; `Zipcode ; `City ; `Country ; `Gender ]

    let details = function 
      | `Firstname -> Form.text     ~name:"firstname" ~label:"member.field.firstname"
      | `Lastname  -> Form.text     ~name:"lastname"  ~label:"member.field.lastname"
      | `Email     -> Form.text     ~name:"email"     ~label:"member.field.email"
      | `Birthdate -> Form.text     ~name:"birthdate" ~label:"member.field.birthdate"
	|> Form.add_js (fun id i18n -> Js.datepicker (Id.sel id) ~lang:(I18n.language i18n) ~ancient:true)
      | `Phone     -> Form.text     ~name:"phone"     ~label:"member.field.phone"
      | `Cellphone -> Form.text     ~name:"cellphone" ~label:"member.field.cellphone"
      | `Address   -> Form.textarea ~name:"address"   ~label:"member.field.address"
      | `Zipcode   -> Form.text     ~name:"zipcode"   ~label:"member.field.zipcode"
      | `City      -> Form.text     ~name:"city"      ~label:"member.field.city"
      | `Country   -> Form.text     ~name:"country"   ~label:"member.field.country"
      | `Gender    -> Form.custom   ~name:"gender"    ~label:"member.field.gender" ~json:false
	~render:(fun (cfg:config) -> cfg # gender) 
      | `Pic       -> Form.custom   ~name:"pic"       ~label:"member.field.picture" ~json:false
	~render:(fun (cfg:config) -> cfg # uploader)

    let hash = Form.prefixed_name_as_hash "member-create" details

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
      type json t = [ `Firstname | `Lastname | `Email | `Birthdate | `Phone | `Pic 
                    | `Cellphone | `Address  | `Zipcode | `City | `Country | `Gender ]
    end)

    let fields  = [ `Firstname ; `Lastname ; `Email ; `Birthdate ; `Phone ; `Pic ;
		    `Cellphone ; `Address  ; `Zipcode ; `City ; `Country ; `Gender ]

    let details = function 
      | `Firstname -> Form.text     ~name:"firstname" ~label:"member.field.firstname"
      | `Lastname  -> Form.text     ~name:"lastname"  ~label:"member.field.lastname"
      | `Email     -> Form.text     ~name:"email"     ~label:"member.field.email"
      | `Birthdate -> Form.text     ~name:"birthdate" ~label:"member.field.birthdate"
	|> Form.add_js (fun id i18n -> Js.datepicker (Id.sel id) ~lang:(I18n.language i18n) ~ancient:true)
      | `Phone     -> Form.text     ~name:"phone"     ~label:"member.field.phone"
      | `Cellphone -> Form.text     ~name:"cellphone" ~label:"member.field.cellphone"
      | `Address   -> Form.textarea ~name:"address"   ~label:"member.field.address"
      | `Zipcode   -> Form.text     ~name:"zipcode"   ~label:"member.field.zipcode"
      | `City      -> Form.text     ~name:"city"      ~label:"member.field.city"
      | `Country   -> Form.text     ~name:"country"   ~label:"member.field.country"
      | `Gender    -> Form.custom   ~name:"gender"    ~label:"member.field.gender" ~json:false
	~render:(fun (cfg:config) -> cfg # gender) 
      | `Pic       -> Form.custom   ~name:"pic"       ~label:"member.field.picture" ~json:false
	~render:(fun (cfg:config) -> cfg # uploader)

    let hash = Form.prefixed_name_as_hash "member-edit" details

  end

  module Form = Form.Make(Fields)

end
