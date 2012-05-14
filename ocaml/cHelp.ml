(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let get_id request = match request # args 0 with 
  | None | Some "" -> IHelp.of_string "index"
  | Some id -> IHelp.of_string id 

(* Display the page if present, 404 otherwise ---------------------------------------------- *)

let () = CCore.register UrlHelp.view begin fun i18n request response ->

  let fail = C404.render i18n response in
  	      
  let id = get_id request in 

  let! page = ohm_req_or fail (MHelp.get id) in
  let! ()   = true_or fail (page # shown) in

  CCore.render
    ~theme:("splash",`RunOrg) 
    ~title:(return (View.esc (page # title)))
    ~body:(
      return (VHelp.Page.render (object
	method title   = page # title
	method content = page # clean
      end) i18n)
    )
    response

end
  
(* Edit the page --------------------------------------------------------------------------- *)

module Edit = FHelp.Page.Edit
module Fields = FHelp.Page.Fields
module Form = FHelp.Page.Form

let () = CAdmin_common.register UrlHelp.edit begin fun i18n user request response ->

  let id = get_id request in
  
  let! page_opt = ohm (MHelp.get id) in

  let edit = match page_opt with 
    | Some p -> (object
      method title = p # title
      method input = p # input
      method links = p # links
      method tags  = p # tags
      method show  = p # shown
    end)
    | None -> (object
      method title = ""
      method input = "" 
      method links = []
      method tags  = []
      method show  = true
    end)
  in

  let body = VHelp.Edit.render (object
    method url = UrlHelp.save # build id
    method init = Form.initialize (function `Page -> Edit.to_json edit) 
  end) i18n in

  return (
    CAdmin_common.layout
      ~js:(JsCode.seq [])
      ~title:(View.esc "Modification Page d'Aide")
      ~body
      response
  )

end

let () = CAdmin_common.register UrlHelp.save begin fun i18n user request response ->

  let fail = CCore.js_fail_message i18n "view.error" response in

  let id = get_id request in

  let form = Form.readpost (request # post) in

  let edit_opt, form = Form.get `Page Edit.fmt form in

  let! edit = req_or fail edit_opt in

  let! () = ohm (
    MHelp.update id 
      ~title: edit # title
      ~input: edit # input
      ~links: edit # links
      ~tags:  edit # tags
      ~shown: edit # show
  ) in

  if edit # show then
    return (Action.javascript (Js.redirect (UrlHelp.view # build id)) response) 
  else
    return (Action.javascript (JsCode.seq []) response)

end


