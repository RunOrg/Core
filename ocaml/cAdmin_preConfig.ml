(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open O
open Ohm.Universal

let () = CAdmin_common.register UrlAdmin.preconfig_compact
  begin fun i18n user request response ->

    let versions = List.rev $ MPreConfigClean.construct_versions () in 

    let output = String.concat "\n\n" (List.map (function 
      | `Template t -> MPreConfig.print_template_version t
      | `Vertical v -> MPreConfig.print_vertical_version v
    ) versions) in

    let apply = request # post "apply" = Some "true" in

    let! () = ohm begin 
      if apply then 
	let t_versions = BatList.filter_map
	  (function `Template t -> Some t | _ -> None) versions
	in
	let v_versions = BatList.filter_map 
	  (function `Vertical v -> Some v | _ -> None) versions
	in
	let! () = ohm $ MPreConfig.Admin.overwrite_template_versions user t_versions in
	let! () = ohm $ MPreConfig.Admin.overwrite_vertical_versions user v_versions in
	return ()
      else
	return ()
    end in 
  
    let html = 
      (if apply then View.str "<h1> Modifications appliquées </h1>" else identity ) 
      |- View.str "<pre>" |- View.esc output |- View.str "</pre>"
    in

    let response = 
      CAdmin_common.layout 
	~title:(View.esc "Préconfiguration - Compaction")
	~body:html
	~js:(JsCode.seq [])
	response
    in

    return response

  end

let () = CAdmin_common.register UrlAdmin.preconfig begin fun i18n user request response ->

  let! templates = ohm (MVertical.Template.admin_all user) in

  let templates = templates |> List.map
      (fun (tid, tname, tkind) -> (object
	method url  = UrlAdmin.edit_template # build tid 
	method id   = ITemplate.to_string tid
	method name = tname
	method kind = tkind
	method edit = UrlAdmin.new_template_version # build_from tid
      end))
  in

  let! verticals = ohm (MVertical.admin_all user) in

  let verticals = verticals |> List.map
      (fun (vid, vname, varchive) -> (object
	method url  = UrlAdmin.edit_vertical # build vid
	method id   = IVertical.to_string vid
	method name = vname
	method archive = varchive
	method edit = UrlAdmin.new_vertical_version # build_from vid
      end))
  in

  let data = object
    method templates = templates
    method verticals = verticals
    method new_vertical = UrlAdmin.edit_vertical # build_create
    method new_template = UrlAdmin.edit_template # build_create
    method new_tmpl_version = UrlAdmin.new_template_version # build
    method new_vert_version = UrlAdmin.new_vertical_version # build 
  end in

  let response = 
    CAdmin_common.layout 
      ~title:(View.esc "Préconfiguration")
      ~body:(VAdmin.PreConfig.Index.Page.render data i18n)
      ~js:(JsCode.seq [])
      response
  in

  return response

end

module NewTemplateVersion = struct

  open FAdmin.PreConfig.TemplateVersionCreate
    
  module Diffs = Fmt.Make(struct
    open MPreConfig
    type json t = TemplateDiff.t list
  end)

  let () = CAdmin_common.register UrlAdmin.new_template_version_post begin fun i18n user request response ->
    
    let! templates = ohm (MVertical.Template.admin_all user) in
    
    let form = Form.readpost (request # post) in 
    
    let form, templates = 
      List.fold_left
	begin  fun (form, templates) (tid,_,_) ->
	  let checked = ref false in 
	  let form = Form.mandatory (`Applies tid) Fmt.Bool.fmt checked (i18n,`label "") form in
	  form, (if !checked then tid :: templates else templates)
	end	
	(form, [])
	templates
    in 

    let diffs = ref [] in 
    
    let form = Form.mandatory `Diffs Diffs.fmt diffs (i18n,`label "") form in 

    let _ = form in

    let! () = ohm (MPreConfig.Admin.create_template_version user templates !diffs) in

    return
      (Action.javascript (Js.redirect (UrlAdmin.preconfig # build)) response)    

  end

end
    
let () = CAdmin_common.register UrlAdmin.new_template_version begin fun i18n user request response ->

  let! templates = ohm (MVertical.Template.admin_all user) in
  let! names = ohm (MPreConfig.name_suggestions) in

  let name_by_tid = List.map (fun (tid,tname,tkind) -> tid,tname) templates in 

  let config = object
    method template_name tid = 
      ListAssoc.try_get name_by_tid tid |> BatOption.default (`label "")
    method autocomplete = names
  end in 

  let! init = ohm begin 
    match request # args 0 with 
      | None -> return  FAdmin.PreConfig.TemplateVersionCreate.Form.empty
      | Some tid -> 
	let! data = ohm (MPreConfig.Admin.of_template user (ITemplate.of_string tid)) in
	return 
	  (FAdmin.PreConfig.TemplateVersionCreate.Form.initialize
	     (function
	       | `Diffs -> Json_type.Build.list MPreConfig.TemplateDiff.to_json data
	       | `Applies _ -> Json_type.Build.bool false))
  end in

  let dyn = new FAdmin.PreConfig.TemplateVersionCreate.Form.dyn config i18n in 

  let checkboxes =
    List.map (fun (tid, tname, tkind) -> 
      (object
	method kind = tkind
	method input = dyn # input (`Applies tid) 
	method label = dyn # label (`Applies tid)
       end)) templates
  in

  let dynamic = List.map (fun (tid, tname, tkind) -> `Applies tid) templates in 

  let data = object
    method checkboxes = checkboxes
    method url        = UrlAdmin.new_template_version_post # build
    method config     = config
    method dynamic    = dynamic
    method init       = init
  end in 

  let response = 
    CAdmin_common.layout
      ~title:(View.esc "Nouvelle version de modèle")
      ~body:(VAdmin.PreConfig.TemplateVersion.Create.render data i18n)
      ~js:(JsCode.seq [])
      response
  in

  return response

end

module NewVerticalVersion = struct

  open FAdmin.PreConfig.VerticalVersionCreate
    
  module Diffs = Fmt.Make(struct
    open MPreConfig
    type json t = VerticalDiff.t list
  end)

  let () = CAdmin_common.register UrlAdmin.new_vertical_version_post begin fun i18n user request response ->
    
    let! verticals = ohm (MVertical.admin_all user) in
    
    let form = Form.readpost (request # post) in 
    
    let form, verticals = 
      List.fold_left
	begin  fun (form, verticals) (vid,_,_) ->
	  let checked = ref false in 
	  let form = Form.mandatory (`Applies vid) Fmt.Bool.fmt checked (i18n,`label "") form in
	  form, (if !checked then vid :: verticals else verticals)
	end	
	(form, [])
	verticals
    in 

    let diffs = ref [] in 
    
    let form = Form.mandatory `Diffs Diffs.fmt diffs (i18n,`label "") form in 

    let _ = form in

    let! () = ohm (MPreConfig.Admin.create_vertical_version user verticals !diffs) in

    return
      (Action.javascript (Js.redirect (UrlAdmin.preconfig # build)) response)    

  end

end
    
let () = CAdmin_common.register UrlAdmin.new_vertical_version begin fun i18n user request response ->

  let! verticals = ohm (MVertical.admin_all user) in
  let! names = ohm (MPreConfig.name_suggestions) in

  let! templates = ohm (MVertical.Template.admin_all user) in

  let names =
    ( MPreConfigNames.template , 
      List.map (fun (id, _, _) -> ITemplate.to_string id) templates ) 
    :: names 
  in

  let name_by_vid = List.map (fun (vid,vname,_) -> vid,vname) verticals in 

  let config = object
    method vertical_name vid = 
      ListAssoc.try_get name_by_vid vid |> BatOption.default (`label "")
    method autocomplete = names
  end in 

  let! init = ohm begin 
    match request # args 0 with 
      | None -> return  FAdmin.PreConfig.VerticalVersionCreate.Form.empty
      | Some vid -> 
	let! data = ohm (MPreConfig.Admin.of_vertical user (IVertical.of_string vid)) in
	return 
	  (FAdmin.PreConfig.VerticalVersionCreate.Form.initialize
	     (function
	       | `Diffs -> Json_type.Build.list MPreConfig.VerticalDiff.to_json data
	       | `Applies _ -> Json_type.Build.bool false))
  end in

  let dyn = new FAdmin.PreConfig.VerticalVersionCreate.Form.dyn config i18n in 

  let checkboxes =
    List.map (fun (vid, vname, varchive) -> 
      (object
	method archive = varchive
	method input   = dyn # input (`Applies vid) 
	method label   = dyn # label (`Applies vid)
       end)) verticals
  in 

  let dynamic = List.map (fun (vid, _, _) -> `Applies vid) verticals in 

  let data = object
    method checkboxes = checkboxes
    method url        = UrlAdmin.new_vertical_version_post # build
    method config     = config
    method dynamic    = dynamic
    method init       = init
  end in 

  let response = 
    CAdmin_common.layout
      ~title:(View.esc "Nouvelle version de vertical")
      ~body:(VAdmin.PreConfig.VerticalVersion.Create.render data i18n)
      ~js:(JsCode.seq [])
      response
  in

  return response

end

let () = CAdmin_common.register UrlAdmin.edit_vertical begin fun i18n user request response ->
  
  let fail = return (Action.redirect (UrlAdmin.preconfig # build) response) in

  let vid = 
    match request # args 0 with Some vid -> Some vid | None -> request # post "create" 
  in

  let! vid = req_or fail vid in
  let vid = IVertical.of_string vid in 

  let! vertical_opt = ohm (MVertical.admin_get user vid) in

  let vertical = vertical_opt |> BatOption.default MVertical.default in

  let init = FAdmin.Vertical.Edit.Form.initialize
    (function `Data -> MVertical.Edit.to_json vertical) 
  in

  let! verticals = ohm (MVertical.admin_all user) in

  let! templates = ohm (MVertical.Template.admin_all user) in   

  let config = object
    val autocomplete = [ 
      MPreConfigNames.i18n, (List.map fst (CAdmin_i18n.get_i18n ())) ;
      MPreConfigNames.template, List.map (fun (id,_,_) -> ITemplate.to_string id) templates ;
      MPreConfigNames.vertical, List.map (fun (id,_,_) -> IVertical.to_string id) verticals ;
    ]  
    method autocomplete = autocomplete
  end in 

  let data = object
    method name = `label vertical # name
    method desc = `label vertical # desc
    method url  = UrlAdmin.edit_vertical_post # build vid
    method config = config
    method init   = init
  end in 

  let response = 
    CAdmin_common.layout
      ~title:(View.esc "Préconfiguration")
      ~body:(VAdmin.PreConfig.Vertical.render data i18n)
      ~js:(JsCode.seq [])
      response
  in
  
  return response 

end

let () = CAdmin_common.register UrlAdmin.edit_vertical_post begin fun i18n user request response ->

  let fail = return response in 

  let! vid = req_or fail (request # args 0) in
  let vid = IVertical.of_string vid in 
  
  let form = FAdmin.Vertical.Edit.Form.readpost (request # post) in
  let data = ref None in 
  
  let form = FAdmin.Vertical.Edit.Form.optional
    `Data MVertical.Edit.fmt data form
  in

  let _ = form in

  let! data = req_or fail !data in
  let! () = ohm (MVertical.admin_set user vid data) in

  return 
    (Action.javascript (Js.redirect (UrlAdmin.preconfig # build)) response)
  
end

let () = CAdmin_common.register UrlAdmin.edit_template begin fun i18n user request response ->
  
  let fail = return (Action.redirect (UrlAdmin.preconfig # build) response) in

  let tid_opt = 
    match request # args 0 with Some tid -> Some tid | None -> request # post "create" 
  in

  let! tid = req_or fail tid_opt in
  let tid = ITemplate.of_string tid in 

  let! template_opt = ohm (MVertical.Template.admin_get user tid) in

  let template = template_opt |> BatOption.default (object
    method name = ""
    method desc = ""
    method kind = `Group
  end) in

  let init = FAdmin.Template.Edit.Form.initialize
    (function `Data -> MVertical.Template.Edit.to_json template) 
  in

  let config = object
    val autocomplete = [ MPreConfigNames.i18n, (List.map fst (CAdmin_i18n.get_i18n ())) ]  
    method autocomplete = autocomplete
  end in 

  let data = object
    method name = `label template # name
    method desc = `label template # desc
    method url  = UrlAdmin.edit_template_post # build tid
    method config = config
    method init   = init
  end in 

  let response = 
    CAdmin_common.layout
      ~title:(View.esc "Préconfiguration")
      ~body:(VAdmin.PreConfig.Template.render data i18n)
      ~js:(JsCode.seq [])
      response
  in
  
  return response 

end

let () = CAdmin_common.register UrlAdmin.edit_template_post begin fun i18n user request response ->

  let fail = return response in 

  let! tid = req_or fail (request # args 0) in
  let tid = ITemplate.of_string tid in 
  
  let form = FAdmin.Template.Edit.Form.readpost (request # post) in
  let data = ref None in 
  
  let form = FAdmin.Template.Edit.Form.optional
    `Data MVertical.Template.Edit.fmt data form
  in

  let _ = form in

  let! data = req_or fail !data in
  let! () = ohm (MVertical.Template.admin_set user tid data) in

  return 
    (Action.javascript (Js.redirect (UrlAdmin.preconfig # build)) response)
  
end
