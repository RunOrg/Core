(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module RemoveFmt = Fmt.Make(struct  
  type json t = IAvatar.t * IAvatar.t list * IInstance.t * IGroup.t 
end)

let remove = 
  
  let task = Task.register "member.remove" RemoveFmt.fmt
    begin fun (from,ids,instance,gid) _ -> 
    
      let finished = Task.Finished (from,ids,instance,gid) in

      (* We're running this task BECAUSE we're removing people from a group. *)
      let gid = IGroup.Assert.write gid in

      (* This is the user we know is performing the removal. *)      
      let from = IAvatar.Assert.is_self from in
      
      let remove aid = MMembership.admin ~from gid aid [ `Accept false ] in
      
      let! _ = ohm $ Run.list_map remove ids in 
      return finished

    end in
  fun (from : [`IsSelf] IAvatar.id) ids instance (write_group : [`Write] IGroup.id) ->
    match ids with 
      | []    -> return () 
      | [aid] -> MMembership.admin ~from write_group aid [ `Accept false ]
      | _     -> let! _ = ohm $ MModel.Task.call task
		   ( IAvatar.decay from,
		     ids,
		     IInstance.decay instance,
		     IGroup.decay write_group )
		 in return ()
	  
let () = CClient.User.register CClient.is_contact (UrlMember.rem ())
  begin fun ctx request response -> 
    
    let i18n = ctx # i18n in
    let panic = Action.javascript Js.panic response in 
    
    let! gid = req_or (return panic) (request # args 0) in
    let  gid = IGroup.of_string gid in
    
    let! group = ohm_req_or (return panic) $ MGroup.try_get ctx gid in
    let! group = ohm_req_or (return panic) $ MGroup.Can.write group in 
	  
    let! from = ohm $ ctx # self in
    
    let! ids = req_or (return panic) $ CMember_common.grab_selected request in	  
	    
    let! () = ohm $ remove
      from ids (IIsIn.instance (ctx # myself)) (MGroup.Get.id group)
    in
    
    let code = 
      JsCode.seq [ 
	Js.message (I18n.get i18n (`label "changes.soon")) ;
	JsBase.boxRefresh 2000.0
      ]	  
    in
    
    return $ Action.javascript code response
  end
      
