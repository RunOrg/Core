(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

module Fields = struct

  type config = { 
    fields : (string * MEntityFields.Field.t) list ;
    render : (string * MEntityFields.Field.t) -> Id.t -> I18n.t -> View.Context.box View.t
  }

  let make_config ~fields ~render = 
    {
      fields = fields ;
      render = render
    }

  let _empty_field = object
    method label = ""
    method explain = None
    method edit  = `hide
    method valid = []
    method mean  = None
  end

  let config = 
    {
      fields = [] ; 
      render = (fun _ _ _ -> View.str "") 
    }

  include Fmt.Make(struct
    type json t = [ `Name | `Status | `Dyn of string ]
  end)

  let fields  = [ `Name ; `Status ]

  module Status = Fmt.Make(struct
    type json t = [ `Draft | `Active | `Delete ]
  end) 

  let details = function  
    | `Name     -> Form.text     ~name:"name"   ~label:"entity.field.name"

    | `Status   -> Form.select   ~name:"status" ~label:"entity.field.status"
      ~values:(fun c -> [ `Draft ; `Active ; `Delete ])
      ~renderer:(fun i18n t -> Status.to_json t , 
	I18n.get i18n (match t with 
	  | `Draft  -> `label "entity.status.draft"
	  | `Active -> `label "entity.status.active"
	  | `Delete -> `label "entity.status.delete"))

    | `Dyn name ->       
      let get_field name config = 
	try name, List.assoc name config.fields with Not_found ->	   
	  log "Entity.Fields.details : unknown field %s" name ;
	  name, _empty_field
      in
      Form.field
	~name

	~json:(fun cfg -> match (snd (get_field name cfg)) # edit with 
	  | `textarea 
	  | `date 
	  | `longtext 
	  | `picture
	  | `hide     -> false
	)

	~label:(fun cfg -> `label ((snd (get_field name cfg)) # label))
	
	~render:(fun id i18n cfg ctx -> cfg.render (get_field name cfg) id i18n ctx)
	
	()     
		     

  let hash = Form.prefixed_name_as_hash "entity-edit" details

end

module Form = Form.Make(Fields)
