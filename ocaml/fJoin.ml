(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

module Fields = struct

  module Status = Fmt.Make(struct
    type json t = 
      [ `Denied 
      | `Accepted 
      | `ToValidate 
      | `Validated 
      | `Invited 
      | `Later 
      | `Asked 
      | `Removed ]      
  end)
  
  let allow_admin   = [ `Validated ; `ToValidate ; `Invited   ; `Removed   ]
  let allow_invited = [ `Accepted  ; `Later      ; `Denied    ]  
  let allow_valid   = [ `Validated ; `Removed    ]
  let allow_normal  = [ `Asked     ; `Removed    ]
  let allow_pending = [ `Asked     ; `Removed    ]

  type config = { 
    fields : (IGroup.t * ((string * MMembership.Field.t) list)) list ;
    render : MMembership.Field.t -> Id.t -> I18n.t -> View.Context.box View.t ;
    allow  : Status.t list 
  }

  let make_config ~fields ~render ~allow = 
    {
      fields = fields ;
      render = render ;
      allow  = allow
    }

  let _empty_field name = object
    method name  = name
    method label = `text ""
    method edit  = `checkbox
    method valid = []
  end

  let config = 
    {
      fields = [] ; 
      render = (fun _ _ _ -> View.str "") ;
      allow  = []
    }

  include Fmt.Make(struct
    module IGroup = IGroup 
    type json t = [ `Status | `Dyn of IGroup.t * string ]
  end)

  let fields  = [ `Status ]

  let of_complete fields = 
    List.concat 
      (List.map
	 (fun (gid,fields) -> List.map (fun (name,_) -> `Dyn (gid,name)) fields)
	 (fields))

  let details = function

    | `Status   ->
      Form.radio ~name:"status" ~label:"join.field.status"
	~values:(fun c -> c.allow)
	~renderer:(fun t -> Status.to_json t , 
	  match t with 
	    | `Denied     -> `label "join.field.status.denied"
	    | `Accepted   -> `label "join.field.status.accepted"
	    | `Validated  -> `label "join.field.status.validated"
	    | `ToValidate -> `label "join.field.status.to_validate"	
	    | `Invited    -> `label "join.field.status.invited"
	    | `Removed    -> `label "join.field.status.removed"
	    | `Later      -> `label "join.field.status.later"
	    | `Asked      -> `label "join.field.status.asked")

    | `Dyn (gid,name) ->       
      let get_field config = 
	try List.assoc name (List.assoc gid config.fields) with Not_found ->	   
	  log "Entity.Fields.details : unknown field %s:%s" (IGroup.to_string gid) name ;
	  _empty_field name
      in
      Form.field
	~name:(IGroup.to_string gid ^ "-" ^ name)

	~json:(fun cfg -> match (get_field cfg) # edit with 
	  | `textarea 
	  | `date 
	  | `longtext 
	  | `checkbox    -> false
	  | `pickMany _
	  | `pickOne  _  -> true
	)

	~label:(fun cfg -> (get_field cfg) # label)
	
	~render:(fun id i18n cfg ctx -> cfg.render (get_field cfg) id i18n ctx)
	
	()     
		     

  let hash = Form.prefixed_name_as_hash "join-edit" details

end

module Form = Form.Make(Fields)
