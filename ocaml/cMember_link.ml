(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let list_id = Id.of_string "link-list" 
let arg_id = "id"

let rem_js bctx remove id =
  Js.runFromServer ~args:(Json_type.Build.objekt [arg_id, IGroup.to_json id]) 
    (bctx # reaction_url remove) 

module Reactions = struct
    
  module MyPicker = CEntityTree.Picker   
	
  let select ~ctx ~add =    
    O.Box.reaction "sel" begin fun self bctx url response ->
      
      let i18n = ctx # i18n in
      let panic = Action.javascript Js.panic response in 
      let self_url arg = bctx # reaction_url self ^ "?a=" ^ arg in
      
      let use_entity id =
	Js.runFromServer
	  ~args:(Json_type.Build.objekt [arg_id, IEntity.to_json (IEntity.decay id)]) 
	  (bctx # reaction_url add)
      in
      
      match bctx # post "a" with 
	| None -> (* No segment yet, display dialog. *)
	  
	  let title = I18n.translate i18n (`label "group.link.pick") in
	  
	  let! body = ohm (
	    MyPicker.at_root 
	      ~root:`Root
	      ~param:(use_entity, (ctx :> 'a MAccess.context))
	      ~me:(IIsIn.user (ctx # myself))
	      ~url:self_url
	      ~i18n
	  ) in
	  
	  return (Action.javascript (Js.Dialog.create body title) response)
	    
	| Some s -> (* Segment provided, display required section. *)
	  
	  let! html = ohm_req_or (return panic) (
	    MyPicker.at_node
	      ~arg:s
	      ~param:(use_entity,(ctx :> 'a MAccess.context))
	      ~me:(IIsIn.user (ctx # myself))
	      ~url:self_url
	      ~i18n
	  ) in
	  
	  return (Action.json (Js.Html.return html) response)
	    
    end 
      
  let add ~ctx ~group ~rem =
    O.Box.reaction "add" begin fun self bctx url response ->
      
      let i18n = ctx # i18n in
      let fail = Action.javascript (Js.message (I18n.get i18n (`label "changes.error"))) response in
      
      let! entity = ohm_req_or (return fail) (
	bctx # post arg_id
	|> BatOption.map IEntity.of_string
	|> Run.opt_bind (MEntity.try_get ctx)
	|> Run.bind (Run.opt_bind MEntity.Can.view)
      ) in
      
      let gid = MEntity.Get.group entity in
      
      let! () = ohm (MGroup.Propagate.add gid (MGroup.Get.id group) ctx) in
      
      let remove = rem_js bctx rem gid in 
      
      let view = VGroup.Link.link
	~remove
	~id:(IGroup.to_id gid)
	~source:(CName.of_entity entity)
	~i18n
      in
      
      return (
	Action.javascript (JsCode.seq [
	  Js.message (I18n.get i18n (`label "changes.saved")) ;
	  Js.appendUniqueList list_id view (IGroup.to_id gid) ;
	  Js.Dialog.close
	]) response	  
      ) 	  
	
    end
      
  let remove ~ctx ~group =
    O.Box.reaction "rem" begin fun self input url response ->
      
      let i18n = ctx # i18n in
      let fail = Action.javascript (Js.message (I18n.get i18n (`label "changes.error"))) response in
      
      let! gid = req_or (return fail) (input # post arg_id) in
      let  gid = IGroup.of_string gid in
      
      let! () = ohm (MGroup.Propagate.rem gid (MGroup.Get.id group)) in
      
      return (
	Action.javascript (JsCode.seq [
	  Js.message (I18n.get i18n (`label "changes.saved")) ;
	  Js.removeParent "tr"
	]) response
      )     
    end
      
end

let get_visible_propagated ctx gid =

  let! groups = ohm (MGroup.Propagate.get gid ctx) in

  let! unfiltered = ohm (
    Run.list_map begin fun group ->

      let! eid = req_or (return None) 
	(MGroup.Get.entity group) 
      in

      let! entity = ohm_req_or (return None)
	(MEntity.try_get ctx eid) 
      in

      let! entity_view = ohm_req_or (return None)
	(MEntity.Can.view entity) 
      in

      return (Some (MGroup.Get.id group , entity_view))
    end groups
  ) in
  
  return (BatList.filter_map identity unfiltered) 

let link_box ~(ctx:'any CContext.full) ~entity ~group = 

  let i18n = ctx # i18n in  
  let gid  = MGroup.Get.id group in

  let! remove = Reactions.remove ~ctx ~group in
  let! add = Reactions.add ~ctx ~group ~rem:remove in
  let! select = Reactions.select ~ctx ~add in

  O.Box.leaf begin fun bctx url -> 
    let! linked = ohm (get_visible_propagated ctx gid) in

    let links =
      List.map (fun (gid, entity) ->
	(object
	  method id     = IGroup.to_id gid
	  method remove = rem_js bctx remove gid
	  method source = CName.of_entity entity 
	 end) 
    ) linked
    in
                
    let current = CName.of_entity entity in
    let url_add = bctx # reaction_url select in
    return (VGroup.Link.page ~id:list_id ~current ~url_add ~links ~i18n)
  end
