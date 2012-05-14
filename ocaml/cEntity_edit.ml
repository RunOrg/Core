(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal
open O

module EditForm = struct
    
  module Fields = FEntity.Fields
  module Form   = FEntity.Form
    
  let reaction ~ctx ~entity ~entity_data =           
    O.Box.reaction "edit-post" begin fun self input (prefix,_) response ->
      
      let i18n     = ctx # i18n in
      let instance = ctx # instance in 
      
      let fields = MEntity.Data.fields entity_data in
      
      let dynamic = List.map (fun (n,f) -> `Dyn n) fields in
      
      let name   = ref None
      and status = ref `Draft in
      
      let form  = Form.readpost ~dynamic (input # post)
      |> Form.optional  `Name   Fmt.String.fmt    name
      |> Form.mandatory `Status Fields.Status.fmt status (i18n,`label "")
      in
      
      let lang   = I18n.language i18n in 
      
      let name   = if !name = Some "" then None else !name in
      
      let! self = ohm (ctx # self) in
      let  cuid = ctx # cuid in 
      
      let data, form = 
	List.fold_left begin fun (data,form) (fname,field) ->
	  let f = `Dyn (fname) in
	  let required = !status = `Active && List.mem `required (field # valid) in
	  let lblreq   = i18n, `label "entity.form.required" in
	  match field # edit with 
	      
	    | `hide -> (data,form) 
	      
	    | `longtext
	    | `textarea ->
	      if required then
		let string = ref "" in 
		let form   = Form.mandatory f Fmt.String.fmt string lblreq form in
		(fname, Json_type.Build.string !string) :: data,
		form
	      else
		let string = ref None in 
		let form   = Form.optional f Fmt.String.fmt string form in 
		(fname, Json_type.Build.optional Json_type.Build.string !string) :: data,
		form
		  
	    | `picture ->
	      if required then
		let pic  = ref (IFile.gen () |> IFile.Assert.get_pic) in 
		let form = Form.mandatory f (CFile.get_pic_fmt cuid) pic lblreq form in
		(fname, IFile.to_json (IFile.decay !pic)) :: data, form
	      else
		let pic  = ref None in 
		let form = Form.optional f (CFile.get_pic_fmt cuid) pic form in 
		(fname, Json_type.Build.optional (IFile.decay |- IFile.to_json) !pic) :: data,
		form
		    
	    | `date ->
	      if required then
		let string = ref "" in 
		let form   = Form.mandatory f (MFmt.date lang) string lblreq form in
		(fname, Json_type.Build.string !string) :: data,
		form
	      else
		let string = ref None in 
		let form   = Form.optional f (MFmt.date lang) string form in 
		(fname, Json_type.Build.optional Json_type.Build.string !string) :: data,
		form
		  
	  end ([], form) fields
	in
	
	if Form.not_valid form then CCore.json_fail (Form.response form) response else begin
	  
	  let! () = ohm begin 
	    MEntity.try_update entity
	      ~status:!status
	      ~name:(BatOption.map (fun t -> `text t) name)
	      ~data
	      (ctx # myself)
	  end in
	
	  let code = 
	    JsCode.seq [ Js.message (I18n.get i18n (`label "changes.saved")) ;
			 JsBase.boxInvalidate ;
			 Js.redirect (UrlR.build instance (input # segments) (prefix,`Info)) ]
	  in
	  
	  return (Action.javascript code response)
	end
    end    
end
  
open Json_type
  
let edit_box ~(ctx:'any CContext.full) ~(entity:[`Admin] MEntity.t) ~entity_data =
  
  let i18n = ctx # i18n in 
  let instance = ctx # instance in 
  let! edit_reaction = EditForm.reaction ~ctx ~entity ~entity_data in
  O.Box.leaf 
    begin fun input (prefix,current) -> 
      
      let cuid = IIsIn.user (ctx # myself) in
      
      let fields = MEntity.Data.fields entity_data in 
      
      let dynamic = List.map (fun (fname,field) -> `Dyn fname) fields in
      let data    = 
	List.map (fun (fname,field) ->
	  let raw =
	    try List.assoc fname (MEntity.Data.data entity_data)
	    with Not_found -> Build.null
	  in
	  fname, CField.initialize i18n cuid (field # edit) raw
	) fields
      in      
      let initialize  = function 
	| `Name     -> Build.optional Build.string (BatOption.map
						      (I18n.translate i18n)
						      (MEntity.Data.name entity_data)) 
	| `Status   -> FEntity.Fields.Status.to_json (MEntity.Get.status entity) 
	| `Dyn name -> try List.assoc name data with Not_found -> Build.null
      in
      let form_init   = FEntity.Form.initialize ~dynamic initialize in
      
      return $ VEntity.Edit.page 
	~form_init
	~form_url:(input # reaction_url edit_reaction)
	~content:(CEntityForm.render_fields instance fields) 
	~config:(CEntityForm.config instance fields)
	~url_cancel:((UrlEntity.root ()) # build instance (MEntity.Get.id entity))
	~dynamic
	~i18n
    end
    
let root_box ~(ctx:'any CContext.full) ~(entity:[`Admin] MEntity.t) =
  
  O.Box.decide begin fun _ _ ->
    
    let! entity_data = ohm_req_or
      (return (O.Box.error (fun _ _ -> return Js.panic)))
      (MEntity.Data.get (MEntity.Get.id entity))
    in
    
    return (edit_box ~ctx ~entity ~entity_data)
      
  end
