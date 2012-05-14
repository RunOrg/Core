(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal
  
let display i18n request response url = 

  let fail =
    let url = 
      if url = "index" then (UrlSplash.index # build ^ "product")
      else UrlCatalog.index # build
    in
    return (Action.redirect url response)
  in

  let! vid = ohm_req_or fail (MVertical.by_url url) in
  let! vertical = ohm_req_or fail (MVertical.get vid) in
  
  let title = "RunOrg - " ^ I18n.translate i18n (`label (vertical # name)) in
  let title = return (View.esc title) in

  let body =

    let create_url = UrlFunnel.pick # build vid in

    let slideshow =
      if vertical # thumbs = [] then None 
      else Some (vertical # thumbs)
    in

    let rec features vertical list = 
      let return = return (vertical # features :: list) in
      let! parent_id = req_or return (vertical # parent) in
      let! parent    = ohm_req_or return (MVertical.get parent_id) in
      features parent (vertical # features :: list)
    in

    let! features = ohm (features vertical []) in
    let! children = ohm (MVertical.by_parent vid) in

    let subverticals = if children = [] then None else Some (
      List.map (fun (id,url,value) ->
	(object
	  method url = UrlCatalog.page # build url 
	  method label = value
	 end)
      ) children
    ) in

    let data = object
      method slideshow = slideshow
      method subverticals = subverticals
      method features = List.rev features
      method description = vertical # desc
      method name = `label vertical # name
      method create = create_url
      method subtitle = vertical # subtitle
      method youcan = vertical # youcan
      method pricing = vertical # pricing
    end in

    return (VCatalog.Page.render data i18n)
  in
    
  let js = JsCode.seq [
    JsBase.staticInit ;
    Js.jQuery ".cycle" "cycle" [] 
  ] in

  CCore.render ~js ~theme:("splash",`RunOrg) ~js_files:CCore.js_catalog ~title ~body response

let () = CCore.register UrlCatalog.index begin fun i18n request response ->

  let! verticals = ohm $ MVertical.get_active in 

  let  boxes = BatList.unique (List.concat (List.map (fun (_,v) -> 
    List.map (#box) (v#catalog)
  ) verticals)) in

  let expanded_verticals = List.concat (List.map (fun (id,v) -> 
    List.map (fun c -> c, id, v) (v # catalog)
  ) verticals) in

  let  verticals_in_box box = 
    let filtered = List.filter (fun (c,_,_) -> c # box = box) expanded_verticals in 
    let sorted   = 
      List.sort (fun (a,_,_) (b,_,_) -> compare (a # order) (b # order)) filtered 
    in
    BatList.filter_map (fun (c,id,v) -> match v # url with None -> None | Some u -> 
      Some (object
	method title   = `label (c # name) 
	method summary = v # summary
	method details = UrlCatalog.page # build u
	method start   = UrlFunnel.pick # build id
      end)
    ) sorted
  in

  let boxes = List.map (fun id -> (object
    method id = id
    method label = `label ("catalog.category."^id)
    method verticals = verticals_in_box id
  end)) boxes in 

  let title = return $ View.esc ("RunOrg - " ^ I18n.translate i18n (`label "catalog.title")) in
  let body  = return $ VCatalog.Index.render boxes i18n in

  CCore.render ~theme:("splash",`RunOrg) ~js_files:CCore.js_catalog ~title ~body response
  
end

let () = CCore.register UrlCatalog.page begin fun i18n request response ->
  display i18n request response (BatOption.default "index" (request # args 0))
end
