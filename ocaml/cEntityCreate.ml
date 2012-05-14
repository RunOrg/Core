(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open O
open BatPervasives
open Ohm.Universal

let pick_templates ~templates
    ~title ~(ctx: 'a CContext.full) =
  O.Box.reaction "pick-templates" begin fun self bctx url response ->
  
    let i18n = ctx # i18n in
    
    let create = UrlEntity.create # build (ctx # instance) in
    
    let dialog = 
      Js.Dialog.create
	(VEntity.chooser_list ~templates ~isin:(ctx # myself) ~create ~i18n)
	(I18n.translate i18n title)
    in
    
    return (Action.javascript dialog response)

  end
    
module PickTemplate = Fmt.Make(struct
  module ITemplate = ITemplate  
  type json t = ITemplate.t * string
end) 
  
let () = CClient.User.register CClient.is_contact UrlEntity.create
  begin fun ctx request response ->
    
    let fail = CCore.js_fail_message (ctx # i18n) "changes.error" response in 
    
    let! template = req_or fail begin 
      request # post "picked"
      |> BatOption.bind PickTemplate.of_json_string_safe
      |> BatOption.bind (fun (id,proof) -> ITemplate.Deduce.from_create_token id (ctx # myself) proof)
    end in
    
    let! id = ohm (MEntity.create template (ctx # myself)) in
    
    let url = (UrlEntity.edit ()) # build (ctx # instance) id in
    let js  = JsCode.seq [ Js.Dialog.close ; Js.redirect url ] in
    return (Action.javascript js response)
      
  end 

