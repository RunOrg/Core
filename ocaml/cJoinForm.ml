(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let box access entity inner =
 
  let  gid   = MEntity.Get.group entity in 

  let render = 

    let! fields = ohm begin
      let! group = ohm_req_or (return []) $ MGroup.naked_get gid in 
      return (MGroup.Fields.get group) 
    end in 

    let! list = ohm $ Run.list_map begin fun field ->
      let! label = ohm (TextOrAdlib.to_string (field # label)) in
      return (object
	method name     = field # name
	method label    = label
	method required = field # required
	method edit     = match field # edit with 
	  | `LongText -> Asset_JoinForm_List_Longtext.render ()
	  | `Textarea -> Asset_JoinForm_List_Textarea.render ()
	  | `Date     -> Asset_JoinForm_List_Date.render ()
	  | `Checkbox -> Asset_JoinForm_List_Checkbox.render ()
	  | `PickOne list -> Asset_JoinForm_List_Pickone.render list
	  | `PickMany list -> Asset_JoinForm_List_Pickmany.render list
      end)      
    end fields in 

    Asset_JoinForm_List.render (object
      method list = list 
    end)

  in
 
  inner render
