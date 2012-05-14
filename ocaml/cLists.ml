(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives
open O

module TheGrid = MAvatarGrid.MyGrid

let get_entity_name ctx = 
  memoize begin fun eid -> 
    Run.memo begin 
      let! entity = ohm_req_or (return None) $ MEntity.try_get ctx eid in
      let! entity = ohm_req_or (return None) $ MEntity.Can.view entity in
      return $ Some (CName.of_entity entity)
    end
  end 

let get_group ctx = 
  memoize (fun id -> Run.memo $ MGroup.try_get ctx id)

let extract_named_source get_entity_name get_group ctx column = 
  let i18n = ctx # i18n in 

  let! src_name = ohm begin 

    match column.MAvatarGrid.Column.eval with 
      | `Avatar     _
      | `Profile    _  -> return $ I18n.translate i18n (`label "column.source.profile")
      | `Group (gid,_) -> 

	let! name_opt = ohm begin 
	  let! group = ohm_req_or (return None) $ get_group gid in
	  let! eid   = req_or (return None) $ MGroup.Get.entity group in
	  get_entity_name eid
	end in
	
	return (
	  name_opt
          |> BatOption.default (`label "column.source.missing")
          |> I18n.translate i18n
	)


  end in

  let! src_field = ohm begin 

    match column.MAvatarGrid.Column.eval with 
      | `Avatar  (_,f) -> return (I18n.translate i18n (`label (
	match f with 
	  | `Name -> "member.field.fullname"
      )))
      | `Profile (_,f) -> return (I18n.translate i18n (`label (
	match f with 
	  | `Firstname -> "member.field.firstname"
	  | `Lastname  -> "member.field.lastname"
	  | `Email     -> "member.field.email"
	  | `Birthdate -> "member.field.birthdate"
	  | `Phone     -> "member.field.phone"
	  | `Cellphone -> "member.field.cellphone"
	  | `Address   -> "member.field.address"
	  | `Zipcode   -> "member.field.zipcode"
	  | `City      -> "member.field.city"
	  | `Country   -> "member.field.country"
	  | `Gender    -> "member.field.gender"
      )))
      | `Group (_,`Status) -> return (I18n.translate i18n (`label "participate.field.state"))
      | `Group (_,`InList) -> return (I18n.translate i18n (`label "participate.field.inlist"))
      | `Group (_,`Date)   -> return (I18n.translate i18n (`label "participate.field.date"))
      | `Group (gid,`Field f) -> 

	let! name_opt = ohm begin  
	  let! group = ohm_req_or (return None) $ get_group gid in
	  let fields = MGroup.Fields.get group in
	  let find field = if field # name = f then Some (field # label) else None in
	  return (try Some (BatList.find_map find fields) with Not_found -> None)
	end in

	return (
	  name_opt
          |> BatOption.default (`label "column.source.missing")
          |> I18n.translate i18n
	)
  end in

  return (src_name ^ " » " ^ src_field)

let extract_named_sources ctx columns = 

  let get_entity_name = get_entity_name ctx in 
  let get_group = get_group ctx in 

  let! list = ohm $ Run.list_map
    (extract_named_source get_entity_name get_group ctx) columns
  in
  return $ BatList.mapi (fun i x -> i,x) list

(* Save edited fields ----------------------------------------------------------------------- *)

module Fields = struct

  let () = CClient.User.register CClient.is_contact (UrlEntity.Option.post_fields ())
    begin fun ctx request response ->
      
      let i18n  = ctx # i18n in
      let panic = 
	Action.javascript (Js.message (I18n.get i18n (`label "changes.error"))) response
      in

      let! gid  = req_or (return panic) (request # args 0) in
      let  gid  = IGroup.of_string gid in

      let! data = req_or (return panic) (request # post "data") in

      let! json = req_or (return panic)
	  (try Some (Json_io.json_of_string ~recursive:true data |> Json_type.Browse.array)
	   with _ -> None)
      in

      let fields  = BatList.filter_map MJoinFields.Field.of_json_safe json in

      let! group = ohm_req_or (return panic) $ MGroup.try_get ctx gid in
      let! group = ohm_req_or (return panic) $ MGroup.Can.admin group in
	
      let! () = ohm $ MGroup.Fields.set group fields in

      return $  	    
	Action.javascript (Js.message (I18n.get i18n (`label "changes.soon"))) response
	
    end      

end

(* Edit field form pop-ups ---------------------------------------------------------------- *)

module EditField = struct

  let list_id = Id.of_string "field-list"

  module Tree = struct     

    include Fmt.Make(struct
      type json t = 
	[ `Root 
        | `Node of [ `text | `date | `choices ]
	]
    end)

    type param  = [`IsContact] CContext.full

    let node_desc = function
      | `text    -> "field.typenode.text", VIcon.textfield
      | `date    -> "field.typenode.date", VIcon.time
      | `choices -> "field.typenode.choices", VIcon.text_list_bullets

    let nodes = [ `text ; `date ; `choices ]

    let type_desc : MJoinFields.FieldType.t -> string = function 
      | `textarea   -> "field.type.textarea"
      | `longtext   -> "field.type.longtext"
      | `date       -> "field.type.date"
      | `checkbox   -> "field.type.checkbox"
      | `pickOne  _ -> "field.type.pickOne"
      | `pickMany _ -> "field.type.pickMany"

    let types = function
      | `text    -> [ `longtext ; `textarea ]
      | `date    -> [ `date ]
      | `choices -> [ `checkbox ; `pickOne [] ; `pickMany [] ]

    let node ctx i18n node = 
      let bullet = VIcon.bullet_black in
      let _i t = I18n.translate i18n (`label t) in
      match node with 

	| `Root -> 
	  return (
	    List.map begin fun node ->
	      let title, icon = node_desc node in 
	      CPicker.node ~title:(_i title) ~icon (`Node node)
	    end nodes
	  )

	| `Node node ->
	  return (
	    List.map begin fun typ ->
	      let title = type_desc typ in 
	      let data = 
		(object
		  method name  = Util.uniq ()
		  method label = `text ""
		  method edit  = typ
		  method valid = []
		 end : MJoinFields.Field.t ) 
	         |> MJoinFields.Field.to_json_string
	      in
	      CPicker.item ~title:(_i title) ~icon:bullet begin
		Js.runFromServer 
		  ~args:(Json_type.Build.objekt [
		    "edit", Json_type.Build.string data
		  ]) 
		  (UrlEntity.Option.form_editfield # build (ctx # instance) (Id.gen ()))
	      end						  
	    end (types node)
	  )

  end

  module MyPicker = CPicker.Make(Tree)

  let () = CClient.User.register CClient.is_contact UrlEntity.Option.form_newfield 
    begin fun ctx request response ->

      let i18n  = ctx # i18n in
      let panic = Action.javascript Js.panic response in      
      let url arg = UrlEntity.Option.form_newfield # build (ctx # instance) ~seg:arg () in 
     
      match request # args 0 with 
	| None -> (* No segment yet, display dialog. *)
	  let title = I18n.translate i18n (`label "field.type.pick") in

	  let! body = ohm $ MyPicker.at_root 
	      ~root:`Root
	      ~param:ctx
	      ~me:(IIsIn.user (ctx # myself))
	      ~url
	      ~i18n
	  in
	  
	  return $ Action.javascript (Js.Dialog.create body title) response

	| Some s -> (* Segment provided, display required section. *)
	  
	  let! html = ohm_req_or (return panic) $ MyPicker.at_node
	      ~arg:s
	      ~param:ctx
	      ~me:(IIsIn.user (ctx # myself))
	      ~url
	      ~i18n
	  in

	  return $ Action.json (Js.Html.return html) response

  end

  (* Edit pop-up *)

  type block = [`Required | `Choice] 

  let blocks_of : MJoinFields.FieldType.t -> block list = function
    | `textarea   -> [`Required]
    | `longtext   -> [`Required]
    | `date       -> [`Required]
    | `pickOne  _ -> [`Choice ; `Required]
    | `pickMany _ -> [`Choice]
    | `checkbox   -> []

  (* Expected to be sequential from 0 to length - 1 *)
  let selectable_choices = [0;1;2;3;4;5] 

  let dynamic_of_block : block -> FField.Edit.Fields.t list = function
    | `Required -> [ `Required ]
    | `Choice   -> List.map (fun x -> `Choice x) selectable_choices 

  let () = CClient.User.register CClient.is_contact UrlEntity.Option.form_editfield
    begin fun ctx request response ->

      let i18n  = ctx # i18n in
      let panic = return response in

      let! the_id   = req_or panic (request # args 0) in
      let  the_id   = Id.of_string the_id in
      let! the_old  = req_or panic (request # post "edit")  in
      let! the_data = req_or panic $ MJoinFields.Field.of_json_string_safe the_old in

      let blocks = blocks_of the_data # edit in 

      let dynamic = List.concat (List.map dynamic_of_block blocks) in 

      let init = FField.Edit.Form.initialize ~dynamic begin function 
	| `Old   -> MJoinFields.Field.to_json the_data
	| `Label -> Json_type.Build.string (I18n.translate i18n (the_data # label))
	| `Required -> Json_type.Build.bool (List.mem `required (the_data # valid))
	| `Choice n -> 
	  let list = match the_data # edit with 
	    | `pickOne  l
	    | `pickMany l -> l
	    | `longtext 
	    | `textarea
	    | `date
	    | `checkbox -> []
	  in
	  try Json_type.Build.string (I18n.translate i18n (List.nth list n)) 
	  with _ -> Json_type.Build.string ""
      end in

      let title = I18n.translate i18n (`label "field.actions.edit") in
      let body  = 
	VLists.Fields.Edit.form
	  ~url:(UrlEntity.Option.post_editfield # build (ctx # instance) the_id)
	  ~dynamic
	  ~blocks
	  ~init
	  ~i18n	  
      in
      
      return (Action.javascript (Js.Dialog.create body title) response)
	
    end     

  module Form = struct

    module Fields = FField.Edit.Fields
    module Form   = FField.Edit.Form

    let () = CClient.User.register CClient.is_contact UrlEntity.Option.post_editfield 
      begin fun ctx request response ->
	
	let i18n = ctx # i18n in

	let labl = ref ""
	and old  = ref None in

	(* Extract generic information *)
	
	let form = Form.readpost (request # post)
	  |> Form.mandatory `Label Fmt.String.fmt      labl (i18n,`label "field.label.required")
	  |> Form.optional  `Old   MJoinFields.Field.fmt old  
	in

	let panic  = Action.json (Form.response form) response in

	let! () = true_or (return panic) $ Form.is_valid form in
	let! old = req_or (return panic) !old in

	(* Extract dynamic field information *)

	let required = ref false in
	let choices  = ref [] in 

	let blocks = blocks_of old # edit in 
	let dynamic = List.concat (List.map dynamic_of_block blocks) in

	let form = 
	  List.fold_left begin fun form item ->
	    match item with 
	      | `Required -> 
		Form.mandatory `Required Fmt.Bool.fmt required (i18n,`label "") form
	      | `Choice   -> 
		let form, list = 
		  List.fold_left (fun (form,list) i ->
		    let v = ref None in 
		    let form = Form.optional (`Choice i) Fmt.String.fmt v form in
		    match !v with None -> form, "" :: list | Some s -> form, s :: list
		  ) (form,[]) (List.rev selectable_choices)
		in
		choices := list ; form			     
	  end (Form.readpost ~dynamic (request # post)) blocks
	in
	
	let! () = true_or (return panic) $ Form.is_valid form in

	(* Construct the field based on read data *)

	let field = object
	  method name  = old # name
	  method label = `text !labl
	  method edit  = 
	    match old # edit with
	      | `textarea   -> `textarea
	      | `longtext   -> `longtext
	      | `checkbox   -> `checkbox
	      | `date       -> `date
	      | `pickOne  _ -> `pickOne  (List.map (fun t -> `text t) !choices) 
	      | `pickMany _ -> `pickMany (List.map (fun t -> `text t) !choices)
	  method valid = 
	    let req = if !required then [`required] else [] in
	    match old # edit with 
	      | `textarea   -> `max 1000 :: req
	      | `longtext   -> `max 80 :: req
	      | `checkbox   -> req
	      | `date       -> req	  
	      | `pickOne  _ -> req
	      | `pickMany _ -> req
	end in
 
	let! the_id = req_or (return panic) (request # args 0) in
	let  the_id = Id.of_string the_id in
	
	let html = 
	  VLists.Fields.field
	    ~url_edit:(UrlEntity.Option.form_editfield # build (ctx # instance))
	    ~field
	    ~i18n
	in
	
	let code = JsCode.seq [
	  Js.Dialog.close ;
	  Js.appendUniqueList list_id html the_id
	] in
	
	return (Action.javascript code response)
      end

  end
end

(* Available column sources ----------------------------------------------------------------- *)

module Sources = struct

  module Tree = struct

    include Fmt.Make(struct
      module IEntity = IEntity
      module EntityKind = MEntityKind
      type json t = 
	[ `Root 
	| `Profile 
	| `Kind of EntityKind.t 
	| `Entity of IEntity.t
	]
    end)
      
    type param  = Id.t * [`IsContact] MAccess.context

    let node (the_id,ctx) i18n (node:t) = 
      let bullet = "/public/icon/bullet_black.png" in
      let _i t = I18n.translate i18n (`label t) in
      match node with 

	| `Root -> 
	  return (
	    [ CPicker.node ~title:(_i "column.source.profile") ~icon:VIcon.user `Profile ] 
	    @ List.map begin fun kind ->
	      CPicker.node 
		~title:(I18n.translate i18n (VLabel.of_entity_kind `plural kind)) 
		~icon:(VIcon.of_entity_kind kind) 
		(`Kind kind)
	    end MEntityKind.all
	  )

	| `Profile -> 
	  let item title what = 
	    let title = _i title in
	    let json = Json_type.Build.list MGroupColumn.Eval.to_json [`profile what] in
	    CPicker.item ~title ~icon:bullet (JsCode.seq [
	      Js.Dialog.close ;
	      Js.appendList the_id (VLists.Edit.AddRem.column
				      ~name:title
				      ~source:(_i "column.source.profile" ^ " » " ^ title)
				      ~show:false
				      ~data:json
				      ~i18n)
	    ])
	  in 
	  return [
	    item "member.field.firstname" `firstname ;
	    item "member.field.lastname"  `lastname ;
	    item "member.field.email"     `email  ;
	    item "member.field.birthdate" `birthdate ;
	    item "member.field.phone"     `phone ;
	    item "member.field.cellphone" `cellphone ;
	    item "member.field.address"   `address ;
	    item "member.field.zipcode"   `zipcode ;
	    item "member.field.country"   `country ;
	    item "member.field.gender"    `gender ;
	  ]

	| `Kind kind -> 
	  let! entities = ohm $ MEntity.All.get_by_kind ctx kind in
	  let  sorted   = 
	    List.sort (fun a b -> compare (MEntity.Get.id b) (MEntity.Get.id a)) entities
	  in	  
	  return $ List.map begin fun entity ->
	    let title = I18n.translate i18n $ CName.of_entity entity in 
	    CPicker.node 
	      ~title
	      ~icon:"/public/icon/table.png" 
	      (`Entity (IEntity.decay (MEntity.Get.id entity)))
	  end sorted

	| `Entity id -> 

	  let! entity = ohm_req_or (return []) $ MEntity.try_get ctx id in 
	  let! entity = ohm_req_or (return []) $ MEntity.Can.view entity in 
	  let! group  = ohm_req_or (return []) $
            MGroup.try_get ctx (MEntity.Get.group entity)
	  in

	  let name = I18n.translate i18n $ CName.of_entity entity in 
	      
	  let item ~title ~eval = 
	    let json = Json_type.Build.array [ 
	      MGroupColumn.Eval.to_json (`join (0,eval)) ;
	      IGroup.to_json (MGroup.Get.id group)
	    ] in
	    CPicker.item ~title ~icon:bullet (JsCode.seq [
	      Js.Dialog.close ;
	      Js.appendList the_id (VLists.Edit.AddRem.column
				      ~name:title
				      ~source:(name ^ " » " ^ title)
				      ~show:true
				      ~data:json
				      ~i18n)
	    ])
	  in
	  
	  return begin 
	    [
	      item (_i "participate.field.state") `state ;
	      item (_i "participate.field.date")  `date ;		
	    ] 
	    @ ( List.map 
		  (fun field -> item 
		    ~title:(match field # label with `label s -> _i s | `text s -> s) 
		    ~eval:(`field (field # name)))
	      	  (MGroup.Fields.get group) )
	  end
  end

  module MyPicker = CPicker.Make(Tree)

  let () = CClient.User.register CClient.is_contact UrlEntity.Option.sources
    begin fun ctx request response ->

      let i18n  = ctx # i18n in
      let panic = Action.javascript Js.panic response in 

      let! the_id = req_or (return panic) (request # args 0) in
      let  the_id = Id.of_string the_id in 

      let url arg = UrlEntity.Option.sources # build (ctx # instance) ~seg:arg the_id in

      match request # args 1 with 
	| None -> (* No segment yet, display dialog. *)

	  let  title = I18n.translate i18n (`label "column.source.pick") in
	  let! body  = ohm $ MyPicker.at_root 
	      ~root:`Root
	      ~param:(the_id, (ctx :> 'a MAccess.context))
	      ~me:(IIsIn.user (ctx # myself))
	      ~url
	      ~i18n
	  in

	  return $ Action.javascript (Js.Dialog.create body title) response

	| Some s -> (* Segment provided, display required section. *)
	  
	  let! html = ohm_req_or (return panic) $ MyPicker.at_node
	      ~arg:s
	      ~param:(the_id, (ctx :> 'a MAccess.context))
	      ~me:(IIsIn.user (ctx # myself))
	      ~url
	      ~i18n
	  in

	  return $ Action.json (Js.Html.return html) response
	  
    end
    
end

(* Column order change --------------------------------------------------------------------- *) 

module Order = struct
    
  module Fields = FColumn.Order.Fields
  module Form   = FColumn.Order.Form

  module Order = Fmt.Make(struct
    type json t = string list
  end)

  let () = CClient.User.register CClient.is_contact (UrlEntity.Option.post_colorder ())
    begin fun ctx request response ->

      let i18n  = ctx # i18n in
      let panic = return $ Action.javascript Js.panic response in 

      let! gid = req_or panic (request # args 0) in
      let  gid = IGroup.of_string gid in 

      let! group = ohm_req_or panic $ MGroup.try_get ctx gid in 
      let! group = ohm_req_or panic $ MGroup.Can.admin group in 

      let  list   = MGroup.Get.listedit group in 
      let  lid    = TheGrid.ListId.of_id $ IAvatarGrid.to_id list in
      let! columns, _, _ = ohm_req_or panic $ TheGrid.get_list lid in 

      let form = ref (Form.readpost (request # post)) in
      
      let sort = ref None in
      
      form := !form |> Form.optional `Order Order.fmt sort ;

      let sort_opt = BatOption.map (fun sort -> 
        let order = List.map (fun s -> int_of_string (BatString.tail s 12)) sort in
	BatList.mapi (fun mvfrom mvto -> (mvto,mvfrom)) order	      
      ) !sort in 

      let sort = match sort_opt with 
	| None      -> BatList.mapi (fun pos _ -> (pos,pos)) columns
	| Some sort -> sort
      in

      let columns = 
	List.sort compare sort
        |> BatList.filter_map (fun (_,mvfrom) ->
	  
	  let show  = ref None 
	  and label = ref None in
	  
	  try let c = BatList.at columns mvfrom in 
	      
	      form := !form
	      |> Form.optional (`Show  mvfrom) Fmt.Bool.fmt   show 
	      |> Form.optional (`Label mvfrom) Fmt.String.fmt label ;
	      
	      let show  = !show = Some true in
	      let label = match !label with Some s -> s | None -> "" in
	      let old   = I18n.translate i18n (c.MAvatarGrid.Column.label) in
	      
	      let label = 
		if label <> old 
		then `text label 
		else c.MAvatarGrid.Column.label
	      in
	      
	      Some MAvatarGrid.Column.({ c with label ; show })
		
	  with _ -> None)
      in

      let form = !form in   
      
      let! () = true_or (return $ Action.json (Form.response form) response) $ 
	Form.is_valid form
      in
      
      let code = 
	JsCode.seq [ 
	  Js.message (I18n.get i18n (`label "changes.saved")) ;
	  Js.runTrigger FColumn.Order.trigger
	]	  
      in
      
      let! () = ohm $ TheGrid.set_columns lid columns in 

      return (Action.javascript code response)
    end
    
end

(* Column add/remove change ---------------------------------------------------------------- *) 

module AddRem = struct

  let trigger = "columns.addrem"

  module Fields = FColumn.Order.Fields
  module Form   = FColumn.Order.Form

  let () = CClient.User.register CClient.is_contact (UrlEntity.Option.post_coladdrem ())
    begin fun ctx request response ->

      let i18n = ctx # i18n in
      let panic = return $ Action.javascript Js.panic response in 

      let iid = IInstance.decay $ IIsIn.instance (ctx # myself) in

      (* The old data, used to retrieve whatever we can. *)
      let! gid = req_or panic (request # args 0) in
      let  gid = IGroup.of_string gid in 

      let! group = ohm_req_or panic $ MGroup.try_get ctx gid in
      let! group = ohm_req_or panic $ MGroup.Can.admin group in 

      (* Grabbing the fields of a group *)	
      let get_fields gid_opt = 
      	match gid_opt with 
	  | None     -> return None
	  | Some gid -> let! group = ohm $ MGroup.try_get ctx gid in
			return $ BatOption.map MGroup.Fields.get group 
      in
      
      let get_fields = memoize (fun id -> Run.memo $ get_fields id) in

      let get_field_view gid_opt name = 
	let default = return `text in 
	let! fields = ohm_req_or default $ get_fields gid_opt in 
	let! field  = req_or default begin 
	  try Some (BatList.find_map 
		      (fun f -> if f # name = name then Some (f # edit) else None)
		      (fields))
	  with _ -> None
	end in 
	return begin match field with 
	  | `textarea
	  | `longtext   -> `text
	  | `date       -> `date
	  | `checkbox   -> `checkbox
	  | `pickOne  _
	  | `pickMany _ -> `pickAny
	end
      in

      let get_view eval gid_opt = 
	match eval with 
	  | `profile `gender    -> return `text (* TODO *)
	  | `profile `birthdate -> return `date
	  | `profile _          -> return `text		  
	  | `join (_,`state)   -> return `status
	  | `join (_,`date)    -> return `datetime
	  | `join (_,`field n) -> get_field_view gid_opt n
      in

      let get_field_label gid_opt name = 
	let default = return (`label "column.source.missing") in 
	let! fields = ohm_req_or default $ get_fields gid_opt in 
	let! label  = req_or default begin 
	  try Some (BatList.find_map 
		      (fun f -> if f # name = name then Some (f # label) else None)
		      (fields))
	  with _ -> None
	end in 
	return label
      in

      let get_label eval gid_opt = 
	match eval with 
	  | `profile x -> return (`label ("member.field."^( match x with  
	      | `firstname -> "firstname"
	      | `lastname  -> "lastname"
	      | `email     -> "email"
	      | `birthdate -> "birthdate"
	      | `phone     -> "phone"
	      | `cellphone -> "cellphone"
	      | `address   -> "address"
	      | `zipcode   -> "zipcode"
	      | `city      -> "city"
	      | `country   -> "country"
	      | `gender    -> "gender" )))
	    
	  | `join (_,`state)   -> return (`label "participate.field.state")
	  | `join (_,`date)    -> return (`label "participate.field.date")
	  | `join (_,`field n) -> get_field_label gid_opt n
      in

      let  list   = MGroup.Get.listedit group in 
      let  lid    = TheGrid.ListId.of_id $ IAvatarGrid.to_id list in
      let! o_columns, _, _ = ohm_req_or panic $ TheGrid.get_list lid in       

      let o_source_self = IGroup.decay (MGroup.Get.id group) in 
      
      (* The list provided by the user. *)
      let! provided = req_or panic (request # post "data") in
      
      let! provided = req_or panic 
	(try Some (Json_type.Browse.array
		     (Json_io.json_of_string ~recursive:true provided))
	 with _ -> None)
      in
      
      let parsed = List.map (fun provided -> 
	try `Old (Json_type.Browse.int provided) 
	with _ -> `New (Json_type.Browse.array provided) 
      ) provided in 
      
      (* Build the new column set and new source set. *)
      
      let build_column n_eval n_source_opt = 
	
	let! view  = ohm $ get_view  n_eval n_source_opt in	    
	let! label = ohm $ get_label n_eval n_source_opt in
	
	let eval = MAvatarGrid.Eval.from_generic
	  iid (BatOption.default gid n_source_opt) n_eval 
	in
	
	let column = MAvatarGrid.Column.({
	  view ;
	  show = true ;
	  label ;
	  eval ;
	}) in
	
	return column
      in

      let n_columns = BatList.filter_map begin function
	(* The user asked for an old column : use existing data. *)
	| `Old num -> 
	  begin 
	    try Some (return $ List.nth o_columns num) with _ -> None 
	  end
	    
	(* User asked for a profile / current item element. *)
	| `New [eval_json] ->
	  begin 	      
	    match MGroupColumn.Eval.of_json_safe eval_json with 
	      | None        -> None
	      | Some n_eval -> Some (build_column n_eval (Some o_source_self))
	  end 
	    
	(* User asked for a new piece of data as a source. *)
	| `New [eval_json;source_json] -> 
	  begin 
	    match IGroup.of_json_safe source_json with 
	      | None -> None
	      | Some n_source -> match MGroupColumn.Eval.of_json_safe eval_json with 
		  | None        -> None
		  | Some n_eval -> Some (build_column n_eval (Some n_source))
	  end
	    
	(* Invalid request *)
	| `New _ -> None
	      
      end parsed in 
      
      let! n_columns = ohm $ Run.list_map identity n_columns in

      let! () = ohm $ TheGrid.set_columns lid n_columns in 

      return (
	Action.javascript (JsCode.seq [
	  Js.message (I18n.get i18n (`label "changes.saved")) ;
	  Js.runTrigger trigger
	]) response
      )

    end
    
end

(* Boxes ----------------------------------------------------------------------------------- *)

let column_order_box ~(ctx:'any CContext.full) ~group = 
  let i18n = ctx # i18n in
  O.Box.leaf
    begin fun input (prefix,_) ->

      let process columns = 

	let sortable = Id.gen () in

	let  dynamic = List.flatten $ BatList.mapi (fun i _ -> [`Show i ; `Label i]) columns in
	let! sourcenames = ohm $ extract_named_sources ctx columns in
	let column n = List.nth columns n in
	let show n = 
	  try Json_type.Build.bool (column n).MAvatarGrid.Column.show
	  with _ -> Json_type.Build.null
	and label n = 
	  try Json_type.Build.string (I18n.translate i18n (column n).MAvatarGrid.Column.label)
	  with _ -> Json_type.Build.null
	in

	let init = 
	  FColumn.Order.Form.initialize
	    ~dynamic
	    (function 
	      | `Order   -> Json_type.Build.null
	      | `Show  n -> show n 
	      | `Label n -> label n) 
	in
	
	let content i18n ctx = 
	  VLists.Edit.Order.columns
	    ~config:()
	    ~list:sortable
	    ~columns:sourcenames
	    ~i18n
	    ctx
	in	 
	
	return $ VLists.Edit.Order.form 
	  ~url:((UrlEntity.Option.post_colorder ()) # build (ctx # instance) group) 
	  ~cancel:(UrlR.build (ctx # instance) (input # segments) (prefix,`View)) 
	  ~id:sortable
	  ~config:()
	  ~dynamic
	  ~init
	  ~content
	  ~i18n
      in
      
      let list = MGroup.Get.listedit group in 
      let lid  = TheGrid.ListId.of_id $ IAvatarGrid.to_id list in 
      let! columns, _, _ = ohm_req_or (return identity) $ TheGrid.get_list lid in 
      process columns

    end
 

let column_summary_box ~(ctx:'any CContext.full) ~group = 
  let i18n = ctx # i18n in
  O.Box.leaf 
    begin fun input (prefix,_) -> 
     
      let  list = MGroup.Get.list group in
      let  lid  = TheGrid.ListId.of_id $ IAvatarGrid.to_id list in  
      let! columns, _, _ = ohm_req_or (return identity) $ TheGrid.get_list lid in 
      let! sources = ohm $ extract_named_sources ctx columns in 
      let  list = BatList.filter_map begin fun (i,source) -> 
	try let column = List.nth columns i in 
	    Some (object
	      method num    = i + 1 
	      method show   = column.MAvatarGrid.Column.show
	      method name   = I18n.translate i18n column.MAvatarGrid.Column.label
	      method source = source
	     end)
	with _ -> None
      end sources in  

      return $ VLists.Edit.Summary.columns
	~url_addrem:(UrlR.build (ctx # instance) (input # segments) (prefix,`Add))
	~url_edit:(UrlR.build (ctx # instance) (input # segments) (prefix,`Order))
	~list
	~i18n
    end
    
let column_addrem_box ~(ctx:'any CContext.full) ~group = 
  let i18n = ctx # i18n in
  O.Box.leaf 
    begin fun input (prefix,_) ->

      let  list = MGroup.Get.list group in
      let  lid  = TheGrid.ListId.of_id $ IAvatarGrid.to_id list in  
      let! columns, _, _ = ohm_req_or (return identity) $ TheGrid.get_list lid in 
      let! sources = ohm $ extract_named_sources ctx columns in 
      let  list = BatList.filter_map begin fun (i,source) -> 
	try let column = List.nth columns i in 
	    Some (object
	      method data   = Json_type.Int i 
	      method show   = column.MAvatarGrid.Column.show
	      method name   = I18n.translate i18n column.MAvatarGrid.Column.label
	      method source = source
	     end)
	with _ -> None
      end sources in  

      let url = UrlR.build (ctx # instance) (input # segments) (prefix,`View) in
      return begin fun vctx -> VLists.Edit.AddRem.page
	~url_save:((UrlEntity.Option.post_coladdrem ()) # build (ctx # instance) group)
	~url_cancel:url
	~url_add:(UrlEntity.Option.sources # build (ctx # instance))
	~columns:list
	~i18n
	(vctx |> View.Context.add_js_code (Js.setTrigger AddRem.trigger (Js.redirect url)))
      end
    end
 

let column_box ~(ctx:'any CContext.full) ~group =   
  O.Box.decide (fun _ ->  
    begin function 
      | _, `Order -> return (column_order_box   ~ctx ~group)
      | _, `Add   -> return (column_addrem_box  ~ctx ~group)
      | _, `View  -> return (column_summary_box ~ctx ~group)
    end)
  |> O.Box.parse CSegs.view_add_order

let field_edit_box ~(ctx:'any CContext.full) ~group = 
  let i18n = ctx # i18n in
  O.Box.leaf
    begin fun input (prefix,_)->
      let fields = MGroup.Fields.get group in 
      return (
	VLists.Fields.page
	  ~list_id:EditField.list_id
	  ~url_save:((UrlEntity.Option.post_fields ()) # build (ctx # instance) group)
	  ~url_add:(UrlEntity.Option.form_newfield # build (ctx # instance) ())
	  ~url_edit:(UrlEntity.Option.form_editfield # build (ctx # instance))
	  ~url_cancel:(UrlR.build (ctx # instance) (input # segments) (prefix, `View))
	  ~fields
	  ~i18n	
      )
    end

let field_view_box ~(ctx:'any CContext.full) ~group = 
  let i18n = ctx # i18n in
  O.Box.leaf
    begin fun input (prefix,_) ->
      let fields = MGroup.Fields.get group in 
      return (
	VLists.Fields.list
	  ~url_edit:(UrlR.build (ctx # instance) (input # segments) (prefix, `Edit))
	  ~fields
	  ~i18n	
      )
    end

let field_box ~(ctx:'any CContext.full) ~group = 
  O.Box.decide (fun _ -> begin function 
    | _, `View -> return (field_view_box ~ctx ~group)
    | _, `Edit -> return (field_edit_box ~ctx ~group)
  end) 
  |> O.Box.parse CSegs.view_edit

