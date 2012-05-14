(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives
open O

module ViewFmt = Fmt.Make(struct
  type json t = [`Private|`Normal|`Public] 
end) 

module CollabFmt = Fmt.Make(struct
  module Format = MEntity.Access.Format
  type json t = Format.t option
end)

let view_source = 
  List.map (fun (key,label) ->
    key, (fun i18n -> I18n.get i18n (`label label))
  ) [ `Private , "entity.view.private.full" ;
      `Normal  , "entity.view.normal.full"  ;
      `Public  , "entity.view.public.full"  ]

let view_collab_source = 
  List.map (fun (key,label) ->
    key, (fun i18n -> I18n.get i18n (`label label))
  ) [ Some `Managers    , "entity.access.managers" ;
      Some `Registered  , "entity.access.registered"  ;
      Some `Viewers     , "entity.access.viewers" ;
      None              , "entity.collab.none" ]

let view_group_source = 
  List.map (fun (key,label) ->
    key, (fun i18n -> I18n.get i18n (`label label))
  ) [ `Managers    , "entity.access.managers" ;
      `Registered  , "entity.access.registered"  ;
      `Viewers     , "entity.access.viewers" ]

let view_votes_source = 
  List.map (fun (key,label) ->
    key, (fun i18n -> I18n.get i18n (`label label))
  ) [ Some `Managers    , "entity.access.managers" ;
      Some `Registered  , "entity.access.registered" ;
      Some `Viewers     , "entity.access.viewers" ;
      None              , "entity.votes.none" ]

let form ~ctx = 

  let! access = ohm (CAccess.field ~ctx) in

  return begin

    Joy.begin_object (fun ~manage ~view ~group ~validate ~collab ~lock ~votes ->
      (object
	method manage   = manage
	method group    = group
	method validate = validate
	method view     = view
	method collab   = collab
	method votes    = votes
	method lock     = lock
       end))

    |> Joy.append (fun f manage -> f ~manage) 
	(access
	   ~label:(`label "entity.field.manage")
	   ~minitip:(`label "entity.field.manage.minitip")
	   (fun seed -> seed # manage))			
      
    |> Joy.append (fun f view -> f ~view) 
	(VQuickForm.choice
	   ~format:ViewFmt.fmt
	   ~source:view_source 
	   ~required:true
	   ~minitip:(`label "entity.field.view.minitip")
	   ~label:(`label "entity.field.view")
	   ~multiple:false
	   (fun _ init -> [init # view])
	   (fun _ field value -> match value with 
	     | [view] -> Ok view
	     |  _     -> Bad (field,`label "field.required"))
	)

    |> Joy.append (fun f group -> f ~group) 
	(VQuickForm.choice
	   ~format:MEntity.Access.Format.fmt
	   ~source:view_group_source 
	   ~required:true
	   ~minitip:(`label "entity.field.view-group.minitip")
	   ~label:(`label "entity.field.view-group")
	   ~multiple:false
	   (fun _ init -> [init # group])
	   (fun _ field value -> match value with 
	     | [view] -> Ok view
	     |  _     -> Bad (field,`label "field.required"))
	)

    |> Joy.append (fun f validate -> f ~validate) 
	(VQuickForm.choice
	   ~format:Fmt.Bool.fmt
	   ~source:[true, fun i18n ctx -> ctx]
	   ~required:true
	   ~minitip:(`label "entity.field.validate.minitip")
	   ~label:(`label "entity.field.validate")
	   ~multiple:true
	   (fun _ init -> if init # validate then [true] else [])
	   (fun _ field value -> match value with 
	     | [true] -> Ok true
	     | []     -> Ok false
	     |  _     -> Bad (field,`label "field.required"))
	)

    |> Joy.append (fun f collab -> f ~collab) 
	(VQuickForm.choice
	   ~format:CollabFmt.fmt
	   ~source:view_collab_source 
	   ~required:true
	   ~minitip:(`label "entity.field.view-collab.minitip")
	   ~label:(`label "entity.field.view-collab")
	   ~multiple:false
	   (fun _ init -> [init # collab])
	   (fun _ field value -> match value with 
	     | [view] -> Ok view
	     |  _     -> Bad (field,`label "field.required"))
	)

    |> Joy.append (fun f lock -> f ~lock) 
	(VQuickForm.choice
	   ~format:Fmt.Bool.fmt
	   ~source:[true, fun i18n ctx -> ctx]
	   ~required:true
	   ~minitip:(`label "entity.field.collab-lock.minitip")
	   ~label:(`label "entity.field.collab-lock")
	   ~multiple:true
	   (fun _ init -> if init # lock then [true] else [])
	   (fun _ field value -> match value with 
	     | [true] -> Ok true
	     | []     -> Ok false
	     |  _     -> Bad (field,`label "field.required"))
	)


    |> Joy.append (fun f votes -> f ~votes) 
	(VQuickForm.choice
	   ~format:CollabFmt.fmt
	   ~source:view_votes_source 
	   ~required:true
	   ~minitip:(`label "entity.field.votes.minitip")
	   ~label:(`label "entity.field.votes")
	   ~multiple:false
	   (fun _ init -> [init # votes])
	   (fun _ field value -> match value with 
	     | [view] -> Ok view
	     |  _     -> Bad (field,`label "field.required"))
	)
	      
    |> Joy.end_object
    |> VQuickForm.wrap
	~submit:(`label "save")
  end

let action_name = "post"
  
let reaction ~ctx ~entity =
  O.Box.reaction "post" begin fun self input _ response ->
    
    let i18n = ctx # i18n in 
    
    (* Read the form *)

    let source = Joy.from_post_json (input # json) in

    let! template = ohm (form ~ctx) in
    let form = Joy.create ~template ~i18n ~source in 
    
    match Joy.result form with 
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return (Action.json json response)

      | Ok result -> 
	
	let! avatar = ohm (ctx # self) in
	
	(* Apply the form *)
	
	let eid = MEntity.Get.id entity in
	let view = result # view in
	let who = `user (Id.gen (), IAvatar.decay avatar) in
	let admin = match result # manage with 
	  | None   -> MEntity.Get.admin entity
	  | Some r -> CAccess.apply (MEntity.Get.admin entity) r
	in

	let autovalid = not result # validate in

	let lock = result # lock in

	let config = 
	  [ `Group_Validation (if autovalid then `none else `manual) ;
	    `Group_Read (result # group) ]
	  @ ( match result # collab with 
	    | None      -> [ `NoWall ; `NoAlbum ; `NoFolder ] 
	    | Some read -> let write = if lock then `Managers else read in 
			   [ `Wall_Write   write ; 
			     `Wall_Read    read ; 
			     `Album_Write  write ; 
			     `Album_Read   read ;
			     `Folder_Write write ;
			     `Folder_Read  read  ])
	  @ ( match result # votes with 
	    | None -> [ `NoVotes ]
	    | Some vote -> [ `Votes_Read `Viewers ;
			     `Votes_Vote vote ])
	in
	
	let! () = ohm $ MEntity.Can.set eid ~who
	  ~view
	  ~admin
	  ~config
	in

	(* Response *)
	
	return
	  (Action.javascript 
	     (Js.message (I18n.get (ctx#i18n) (`label "changes.saved")))
	     response)
  end
        
let box ~(ctx:'any CContext.full) ~entity = 
  let! reaction = reaction ~ctx ~entity in
  O.Box.leaf begin fun input url ->
    
    let view = MEntity.Can.view_access entity in
    let public = MEntity.Get.public entity in 
    let validate = 
      match MEntity.Get.config entity
        |> (#group)
        |> BatOption.map (#validation)
        |> BatOption.default `none 
      with
	| `none   -> false
	| `manual -> true 
    in

    let collab = 
      MEntity.Get.config entity
      |> (#wall) 
      |> BatOption.map (#read)  
    in

    let group = 
      MEntity.Get.config entity
      |> (#group) 
      |> BatOption.map (#read)  
    in

    let collab_write = 
      MEntity.Get.config entity
      |> (#wall) 
      |> BatOption.map (#post)  
    in

    let votes = 
      MEntity.Get.config entity
      |> (#votes) 
      |> BatOption.map (#vote)  
    in

    let lock = (collab_write = Some `Managers) && (collab <> Some `Managers) in
    
    let rec to_members = function
    
      | `Union l -> List.exists to_members l  
	
      | `Token   -> true
	
	  (* This is a gross oversimplification, but the form itself is not complex enough to 
	     handle the full expressive power of the access system... so treat the absence of
	     `Token as a custom private entity
	  *)
      | _        -> false
	
    in

    let! template = ohm (form ~ctx) in
    let form = 
      Joy.create ~template ~i18n:(ctx#i18n) 
	~source:(Joy.from_seed 
	   (object 
	     method view = if public then `Public else
		if to_members view then `Normal else `Private
	     method group  = BatOption.default `Managers group 
	     method manage = CAccess.extract (MEntity.Get.admin entity) 
	     method collab = collab
	     method validate = validate
	     method lock = lock 
	     method votes = votes
	    end))
    in

    let renderer i18n ctx = Joy.render form (input # reaction_url reaction) ctx in
   
    return (renderer (ctx # i18n))
  end 

