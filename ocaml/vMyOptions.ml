(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "myOptions" name

let _home_page = 
  let _fr = load "head" [
    "content" , Mk.html (#content |- O.Box.draw_container) ;
  ] `Html in
  function `Fr -> _fr

let home_page ~content ~i18n ctx = 
  to_html (_home_page (I18n.language i18n)) (object
    method content = content
  end) i18n ctx

module Share = struct

  let _page = 
    let _fr = load "share" begin
      [
	"explain", Mk.itext (fun x i -> I18n.get_param i "profile.share.what" [ View.esc (x # asso) ]) ;
      ] |> FShare.Profile.Form.to_mapping 
	~prefix:"share-profile"
	~url:    (#form_url)
	~init:   (#form_init)
    end `Html in
    function `Fr -> _fr
      

  let page ~asso ~form_url ~form_init ~i18n ctx = 
    to_html (_page (I18n.language i18n)) (object
      method asso      = asso
      method form_url  = form_url
      method form_init = form_init
    end) i18n ctx

end

module Info = struct

  let _picture = 
    let _fr = load "info-basic-picture" [
      "picture",   Mk.esc (#picture)  
    ] `Html in
    function `Fr -> _fr

  let _name = 
    let _fr = load "info-basic-name" [
      "name", Mk.trad (#fullname) ;
    ] `Html in
    function `Fr -> _fr

  let _item = 
    let _fr = load "info-imported" [
      "label", Mk.trad (#label) ;
      "value", Mk.str  (#value) ;
    ] `Html in
    function `Fr -> _fr

  let _page = 
    let _fr = load "info" begin
      [
	"import-head",    Mk.trad   (fun x -> if x # source = [] then `label "profile.import.none" else `label "profile.import.title") ;
	"import-picture", Mk.sub_or (#basic) (_picture `Fr) (Mk.empty) ;
	"import-name",    Mk.sub_or (#basic) (_name `Fr) (Mk.empty) ;
	"import",         Mk.list   (#import) (_item `Fr) ;
	"options-url",    Mk.esc    (#options_url) ;      
      ] |> FMember.Edit.Form.to_mapping 
	~prefix:"member-edit"
	~url:    (#form_url)
	~init:   (#form_init)
	~config: (#form_config) 
    end `Html in
    function `Fr -> _fr

  let page 
      ~(source:MFieldShare.t list)
      ~form_url
      ~form_init
      ~uploader
      ~gender
      ~options_url
      ~picture
      ~data
      ~name
      ~i18n ctx = 

    let form_config = object
      method uploader = uploader
      method gender   = gender
    end in

    let shares x = List.mem x source in
    let lang     = I18n.language i18n in
    let opt      = function Some s -> View.write_to_string (View.esc s) | None -> "" in

    to_html (_page lang) (object
      method source      = source
      method options_url = options_url
      method form_url    = form_url
      method form_init   = form_init
      method form_config = form_config

      method basic       = if shares `basic then Some (object 
	method fullname  = name
	method picture   = picture
      end) else None

      method import      = BatList.filter_map (function
	| `basic -> None
	| `birth -> Some ( object 
	  method label = `label "account.field.birthdate"
	  method value = opt (BatOption.map (MFmt.date_string lang) (data.MProfile.Data.birthdate)) 
	end ) 
	| `email -> Some ( object
	  method label = `label "account.field.email"
	  method value = opt (data.MProfile.Data.email)
	end )
	| `phone -> Some ( object
	  method label = `label "account.field.phone"
	  method value = opt (data.MProfile.Data.phone) 
	end ) 
	| `cellphone -> Some ( object
	  method label = `label "account.field.cellphone"
	  method value = opt (data.MProfile.Data.cellphone) 
	end ) 
	| `address -> Some ( object
	  method label = `label "account.field.address"
	  method value = opt (data.MProfile.Data.address)
	end )
	| `city -> Some ( object
	  method label = `label "account.field.city"
	  method value = opt (data.MProfile.Data.zipcode) ^ " " ^ opt (data.MProfile.Data.city) 
	end ) 
	| `country -> Some ( object
	  method label = `label "account.field.country"
	  method value = opt (data.MProfile.Data.country)
	end  )
	| `gender  -> Some ( object
	  method label = `label "account.field.gender"
	  method value = match data.MProfile.Data.gender with 
	    | None -> ""
	    | Some `m -> "<img src='" ^ VIcon.male ^ "'/>"
	    | Some `f -> "<img src='" ^ VIcon.female ^ "'/>"
	end ) 
      )	source 
    end) i18n ctx

  
end

