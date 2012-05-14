(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let contact_picker = CMember_common.contact_picker

module Link       = CMember_link
module Validate   = CMember_validate
module Picker     = CMember_picker
module RemoveMany = CMember_removeMany

(* CSend out list of contacts starting with a certain sequence ------------------------------ *)

module Autocomplete = struct

  (* This is the old aucotomplete. The joy autocomplete is in member_picker.ml *)
  let () = CClient.User.register CClient.is_contact UrlMember.autocomplete 
    begin fun ctx request response ->

      let i18n  = ctx # i18n in
      let panic = Action.json [ "val" , Json_type.Build.array []] response in

      let! term  = req_or (return panic) (request # post "term") in
      let! proof = req_or (return panic) (request # args 0) in

      let inst  = IIsIn.instance (ctx # myself) in
      let user  = IIsIn.user     (ctx # myself) in 

      let! see = req_or (return panic)
	(IInstance.Deduce.from_seeContacts_token inst user proof)
      in
      
      let count = 4 in 

      let! avatars = ohm $ MAvatar.search see term count in

      let! list = ohm $ Run.list_map begin fun (id, prefix, details) ->

	let status  = ctx # status 
	  (match details # status with Some x -> x | None -> `Contact) in

	let name    = CName.get i18n details in 
	
	let! pic = ohm $ ctx # picture_small (details # picture) in
	
	let html, _ = View.extract (VMember.Autocomplete.item ~name ~status ~pic ~i18n) in
	let value   = Json_io.string_of_json ~recursive:true ~compact:true 
	  (Json_type.Build.array [
	    Json_type.Build.string (IAvatar.to_string id) ;
	    Json_type.Build.string name
	  ])
	in
	
	return $ Json_type.Build.objekt [
	  "label",   Json_type.Build.string name ; 
	  "payload", Json_type.Build.string value ;
	  "html",    Json_type.Build.string html
	]
	        
      end avatars in 
	
      return $ Action.json [ "val" , Json_type.Build.array list ] response

    end
    
end
