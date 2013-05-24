(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module AllowFmt = Fmt.Make(struct
  type json t = <
    iid : IInstance.t ;
    allow : bool 
  >
end) 

let () = define UrlMe.Notify.def_block begin fun owid cuid -> 

  let! set = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 

    let respond allowed = 
      return (Action.json [ "allowed", Json.Bool allowed ] res )  in
    
    let! args = req_or (return res) (AllowFmt.of_json_safe json) in
    let  uid  = IUser.Deduce.can_block cuid in 
    let! ()   = ohm (MMail.Spam.set uid (args # iid) (args # allow)) in
    
    respond (args # allow) 

  end in 

  O.Box.fill begin

    let! sta_iids  = ohm (MAvatar.user_instances (IUser.Deduce.can_view_inst cuid)) in
    let! instances = ohm (Run.list_filter (snd |- MInstance.get) sta_iids) in 
    let  instances = List.sort (fun a b -> compare (a # name) (b # name)) instances in 

    let uid = IUser.Deduce.can_block cuid in 
    
    let! items = ohm (Run.list_map begin fun instance -> 
      let! allowed = ohm (MMail.Spam.get uid (instance # id)) in
      let  allowed = BatOption.default true allowed in 
      return (object
	method name = instance # name
	method allowed = allowed
	method id = IInstance.to_string (instance # id)
      end) 
    end instances) in 

    let body = Asset_Notify_Block.render (object
      method items = items 
      method post  = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint set ()) 
    end) in
    
    Asset_Admin_Page.render (object
      method parents = [ object
	method url   = Action.url UrlMe.Notify.settings owid () 
	method title = AdLib.get `Notify_Settings_Title
      end ] 
      method here  = AdLib.get `Notify_Settings_Block_Title
      method body  = body
    end)

  end
end
