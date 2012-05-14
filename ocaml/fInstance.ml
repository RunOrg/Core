(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Edit = struct

  module Fields = struct
      
    type config = <
      uploader : Id.t -> string -> View.Context.box View.t ;
    > ;;

    let config  = (object 
      method uploader _ _ = View.esc "[Please use non-default config]" 
    end)

    include Fmt.Make(struct
      type json t = [ `Name | `Desc | `Address | `Site | `Pic | `Contact
		    | `Facebook | `Twitter | `Phone | `Tags ]
    end)

    let fields  = [ `Name ; `Desc ; `Address ; `Site ; `Pic ; `Contact
		  ; `Facebook ; `Twitter ; `Phone ; `Tags ]

    let details = function 
      | `Name      -> Form.text     ~name:"name" ~label:"instance.field.name"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 80 id)
      | `Desc      -> Form.textarea ~name:"desc" ~label:"instance.field.desc"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 3000 id) 
      | `Address   -> Form.textarea ~name:"address" ~label:"instance.field.address"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 300 id) 
      | `Site      -> Form.text     ~name:"site"     ~label:"instance.field.site"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Contact   -> Form.text     ~name:"contact"  ~label:"instance.field.contact"
        |> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Tags      -> Form.text     ~name:"tags"     ~label:"instance.field.tags"
      | `Facebook  -> Form.text     ~name:"facebook" ~label:"instance.field.facebook"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Twitter   -> Form.text     ~name:"twitter"  ~label:"instance.field.twitter"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Phone     -> Form.text     ~name:"phone"    ~label:"instance.field.phone"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 20 id)
      | `Pic       -> Form.custom   ~name:"pic"      ~label:"instance.field.pic" ~json:false
	~render:(fun (cfg:config) -> cfg # uploader)

    let hash = Form.prefixed_name_as_hash "asso-edit" details

  end

  module Form = Form.Make(Fields)

end

module AdminEdit = struct

  module Fields = struct
      
    type config = <
      uploader : Id.t -> string -> View.Context.box View.t ;
    > ;;

    let config  = (object 
      method uploader _ _ = View.esc "[Please use non-default config]" 
    end)

    include Fmt.Make(struct
      type json t = [ `Name | `Key | `Desc | `Address | `Site | `Pic | `Contact
		    | `Facebook | `Twitter | `Phone | `Tags | `Visible | `RSS ]
    end)

    let fields  = [ `Name ; `Key ; `Desc ; `Address ; `Site ; `Pic ; `Contact
		  ; `Facebook ; `Twitter ; `Phone ; `Tags ; `Visible ; `RSS ]

    let details = function 
      | `Name      -> Form.text     ~name:"name" ~label:"instance.field.name"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 80 id)
      | `Key       -> Form.text     ~name:"key"  ~label:"instance.field.key"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 32 id)
      | `Desc      -> Form.textarea ~name:"desc" ~label:"instance.field.desc"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 3000 id) 
      | `Address   -> Form.textarea ~name:"address" ~label:"instance.field.address"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 300 id) 
      | `Site      -> Form.text     ~name:"site"     ~label:"instance.field.site"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Contact   -> Form.text     ~name:"contact"  ~label:"instance.field.contact"
        |> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Tags      -> Form.text     ~name:"tags"     ~label:"instance.field.tags"
      | `Facebook  -> Form.text     ~name:"facebook" ~label:"instance.field.facebook"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Twitter   -> Form.text     ~name:"twitter"  ~label:"instance.field.twitter"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 100 id)
      | `Phone     -> Form.text     ~name:"phone"    ~label:"instance.field.phone"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 20 id)
      | `Pic       -> Form.custom   ~name:"pic"      ~label:"instance.field.pic" ~json:false
	~render:(fun (cfg:config) -> cfg # uploader)
      | `Visible   -> Form.checkbox ~name:"visible" ~label:"instance.field.visible"
      | `RSS       -> Form.textarea ~name:"rss"     ~label:"instance.rss.address"

    let hash = Form.prefixed_name_as_hash "asso-admin-edit" details

  end

  module Form = Form.Make(Fields)

end
