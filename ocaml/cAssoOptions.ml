(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives
open O

(* Rights edit action ---------------------------------------------------------------------- *)

module RightsEdit = struct

  module ViewFmt = Fmt.Make(struct
    type json t = [`Private|`Normal|`Public]
  end) 

  let view_source = 
    List.map (fun (key,label) ->
      key, (fun i18n -> I18n.get i18n (`label label))
    ) [ `Private , "access.private" ;
	`Normal  , "access.normal"  ;
	`Public  , "access.public"  ]
   
  let form ~ctx = 
    Joy.begin_object (fun ~directory ~freeze ->
      MInstanceAccess.Data.({
	directory ; freeze
      }))

    |> Joy.append (fun f directory -> f ~directory) 
	(VQuickForm.choice
	   ~format:ViewFmt.fmt
	   ~source:view_source
	   ~multiple:false
	   ~required:true
	   ~minitip:(`label "asso.rights.directory.minitip")
	   ~label:(`label "asso.rights.directory")
	   (fun _ init -> match init.MInstanceAccess.Data.directory with 
	     | `Contact -> [`Public]
	     | `Token   -> [`Normal]
	       (* Yes, this is quite approximative... *)
	     | _        -> [`Private])
	   (fun _ field value -> match value with 
	     | [`Public]  -> Ok `Contact
	     | [`Normal]  -> Ok `Token
	     | [`Private] -> Ok `Nobody
	     | _          -> Bad (field,`label "field.required")))
	
    |> Joy.append (fun f freeze -> f ~freeze) 
	(VQuickForm.choice
	   ~format:Fmt.Bool.fmt
	   ~source:[true, fun i18n ctx -> ctx]
	   ~required:true
	   ~minitip:(`label "asso.rights.freeze.minitip")
	   ~label:(`label "asso.rights.freeze")
	   ~multiple:true
	   (fun _ init -> if init.MInstanceAccess.Data.freeze then [true] else [])
	   (fun _ field value -> match value with 
	     | [true] -> Ok true
	     | []     -> Ok false
	     |  _     -> Bad (field,`label "field.required"))
	)

    |> Joy.end_object
    |> VQuickForm.wrap 
	~submit:(`label "save")

  let reaction ~ctx = 
    O.Box.reaction "edit-rights" begin fun self bctx _ response ->
      
      let form = Joy.create
	~template:(form ~ctx) 
	~i18n:(ctx # i18n)
	~source:(Joy.from_post_json (bctx # json))
      in

      match Joy.result form with 
	| Bad errors ->

	  let json = Joy.response (Joy.set_errors errors form) in
	  return (Action.json json response)

	| Ok result ->

	  let id = IIsIn.instance (ctx # myself) in
	  let! () = ohm (MInstanceAccess.set id result) in
	  
	  (* Response *)
	  
	  return
	    (Action.javascript 
	       (Js.message (I18n.get (ctx#i18n) (`label "changes.saved")))
	       response)

    end

end

let rights_box ~ctx = 

  let! reaction = RightsEdit.reaction ~ctx in

  O.Box.leaf begin fun bctx _ ->

    let! rights = ohm (MInstanceAccess.get (IIsIn.instance (ctx # myself))) in

    let form = Joy.create
      ~template:(RightsEdit.form ~ctx)
      ~i18n:(ctx # i18n)
      ~source:(Joy.from_seed rights) 
    in

    return (Joy.render form (bctx # reaction_url reaction))

  end

(* Asso edit action ------------------------------------------------------------------------ *)

module AssoEdit = struct

  module Fields = FInstance.Edit.Fields
  module Form   = FInstance.Edit.Form

  let reaction ~ctx = 
    O.Box.reaction "edit-asso" begin fun self bctx data response ->
      
      let i18n = ctx # i18n in
      let cuid = IIsIn.user (ctx # myself) in 
      
      let name     = ref ""
      and desc     = ref None
      and site     = ref None
      and pic      = ref None
      and address  = ref None
      and contact  = ref None 
      and facebook = ref None
      and twitter  = ref None
      and phone    = ref None
      and tags     = ref None in
      
      let form = Form.readpost (bctx # post)
        |> Form.mandatory `Name     Fmt.String.fmt name     (i18n,`label "instance.field.name.required")
	|> Form.optional  `Desc     Fmt.String.fmt desc
	|> Form.optional  `Site     Fmt.String.fmt site
	|> Form.optional  `Pic      (CFile.get_pic_fmt cuid) pic
	|> Form.optional  `Address  Fmt.String.fmt address
	|> Form.optional  `Contact  Fmt.String.fmt contact
	|> Form.optional  `Facebook Fmt.String.fmt facebook
	|> Form.optional  `Twitter  Fmt.String.fmt twitter	
	|> Form.optional  `Phone    Fmt.String.fmt phone
	|> Form.optional  `Tags     Fmt.String.fmt tags
      in      
      
      if Form.not_valid form then 
	return (Action.json (Form.response form) response)
      else      
      
	let iid = IInstance.Deduce.admin_edit (IIsIn.instance ctx # myself) in     
	
	let! pic = ohm $
	  Run.opt_bind (MFile.instance_pic (IInstance.decay iid)) !pic
	in

	let tags = 
	  let source = BatOption.default "" !tags in
	  let regex  = Str.regexp "[ ,.;]+" in
	  Str.split regex source
	in
	  
	let! _ = ohm $ MInstance.update
	  iid
	  ~pic
	  ~desc:!desc
	  ~site:!site
	  ~name:!name
	  ~address:!address
	  ~contact:!contact
	  ~facebook:!facebook
	  ~twitter:!twitter
	  ~phone:!phone
	  ~tags
	in
	
	let code = 
	  JsCode.seq [
	    Js.message (I18n.get i18n (`label "changes.saved")) ;
	    JsBase.boxRefresh 100.0
	  ]
	in
	
	return $ Action.javascript code response
    end
      
end

let edit_box ~ctx =

  let! post = AssoEdit.reaction ~ctx in

  let cuid = IIsIn.user (ctx # myself) in
  O.Box.leaf
    begin fun bctx url ->
      
      let  iid     = IInstance.decay (IIsIn.instance (ctx # myself)) in
      let! profile = ohm $ MInstance.Profile.get iid in
      let  profile = BatOption.default (MInstance.Profile.empty iid) profile in 

      let init = FInstance.Edit.Form.initialize 
	Json_type.Build.(MInstance.Profile.(begin function
	  | `Name     -> string profile # name
	  | `Desc     -> optional string profile # desc
	  | `Address  -> optional string profile # address
	  | `Pic      -> optional (CFile.get_pic_fmt cuid).Fmt.to_json (ctx # instance # pic)
	  | `Site     -> optional string profile # site
	  | `Contact  -> optional string profile # contact
	  | `Facebook -> optional string profile # facebook
	  | `Twitter  -> optional string profile # twitter
	  | `Phone    -> optional string profile # phone
	  | `Tags     -> string (String.concat ", " (List.map String.lowercase profile#tags))
	end))
      in
      return (
	VAssoOptions.editform 
	  ~uploader:(CFile.client_pic_uploader (ctx # instance))
	  ~form_url:(bctx # reaction_url post) 
	  ~form_init:init
	  ~i18n:(ctx # i18n)
      )
    end

(* The box containing the tabs ------------------------------------------------------------- *)

let home_box ~ctx = 
  let tabs ~ctx = 
    let list = 
      (	CTabs.fixed `Asso   (`label "asso-options.tab.asso")   (lazy (edit_box ~ctx)) ) ::
	begin 
	  if ctx # instance # stub then [] else
	    [ 
	      CTabs.fixed `Rights (`label "asso-options.tab.rights") (lazy (rights_box ~ctx)) ;
	    ]
	end
    in

    CTabs.box
      ~list
      ~url:(UrlR.build (ctx # instance))
      ~i18n:(ctx # i18n)
      ~default:`Asso
      ~seg:CSegs.asso_tabs
  in
  let content = "c" in
  O.Box.node
    begin fun input _ ->
      match IIsIn.Deduce.is_admin (ctx # myself) with
	| None -> return [], return (VCore.admin_only ~i18n:(ctx # i18n))
	| Some isin ->
	  let ctx = CContext.evolve_full isin ctx in 
	  return [content, tabs ~ctx],
	  return 
	    (VAssoOptions.home_page ~content:(input # name,content) ~i18n:(ctx # i18n))
    end
      
