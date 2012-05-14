(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Self = CJoin_self

module Validate = struct

  let validate_one from aid group = 
    let gid = MGroup.Get.id group in
    MMembership.admin ~from gid aid [ `Accept true ] 

  module TaskArgs = Fmt.Make(struct
    type json t = <
      self  : IAvatar.t ;
      list  : IAvatar.t list ;
      group : IGroup.t 
    >
  end)

  let validate_many_task = 
    Task.register "join-validate-many" TaskArgs.fmt begin fun args _ ->

      (* Restoring properties *)
      let self    = IAvatar.Assert.is_self (args # self) in
      let gid     = IGroup.Assert.write (args # group) in
      let finish  = return (Task.Finished args) in
      let joins   = args # list in 

      (* Running loop *)
      let! group_opt = ohm (MGroup.naked_get gid) in
      let! group = req_or finish group_opt in

      let! _ = ohm (Run.list_map begin fun join ->
	validate_one self join group 
      end joins) in
      
      finish 

    end 

  let validate_many ~self ~group ~joins =  
    match joins with 
      | [] -> return None
      | [join] -> let! () = ohm $ validate_one self join group in return None
      | _ -> let args = 
	       ( object
		 method self  = IAvatar.decay self
		 method group = IGroup.decay (MGroup.Get.id group) 
		 method list  = joins
		 end ) 
	     in
	     let! token = ohm (MModel.Task.call validate_many_task args) in
	     return (Some token)	    

end

module Remove = struct

  let () = CClient.User.register CClient.is_contact (UrlJoin.remove ())
    begin fun ctx request response ->
        
      let i18n = ctx # i18n in
    
      let fail = 
	Action.javascript (Js.message (I18n.get i18n (`label "changes.error"))) response
      in
      
      let! gid = req_or (return fail) (request # args 0) in
      let  gid = IGroup.of_string gid in 

      let! aid = req_or (return fail) (request # args 1) in
      let  aid = IAvatar.of_string aid in

      let! self  = ohm $ ctx # self in
      let! group = ohm_req_or (return fail) $ MGroup.try_get ctx gid in
	  
      let! writable_group = ohm $ MGroup.Can.write group in

      let! () = ohm $ begin match writable_group with 
	| None       -> 
	  if aid = IAvatar.decay self
	  then MMembership.user gid self false
	  else return ()
	| Some group -> 
	  MMembership.admin ~from:self (MGroup.Get.id group) aid
	    [ `Accept false ; `Default false ]
      end in 

      let code = 
	JsCode.seq [ Js.message (I18n.get i18n (`label "changes.soon")) ;
		     JsBase.boxRefresh 200.0]
      in
	      
      return (Action.javascript code response)

    end
    
end

module Edit = CJoin_edit


