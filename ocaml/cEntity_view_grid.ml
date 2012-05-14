(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module TheGrid = MAvatarGrid.MyGrid
module Search = CEntity_view_search

let box ~(ctx:[<`IsToken|`IsAdmin] CContext.full) ~entity ~group = 
  let i18n = ctx # i18n in 
  let inst = ctx # instance in 
  
  O.Box.decide begin fun _ (_,aid_opt) ->

    match aid_opt with 
      | None -> begin 

	let list = MGroup.Get.list group in

	let! view_directory = ohm (MInstanceAccess.can_view_directory ctx) in
    
	let locked = O.Box.leaf begin fun input _ -> 
	  let user = ctx # myself |> IIsIn.user in
	  let url = UrlClient.ckgrid # build inst user list in 
	  return (VMember.Category.List.locked ~url ~i18n)
	end in

	let  lid    = TheGrid.ListId.of_id $ IAvatarGrid.to_id list in 

	let! status = ohm_req_or (return locked) $ TheGrid.check_list lid in
	let! () = true_or (return locked) begin match status with 
	  | `Unlocked
	  | `LineLocked -> true
	  | `ColumnLocked -> false
	end in
  
	let! columns, _, _ = ohm_req_or (return locked) $ TheGrid.get_list lid in  

	return begin 
	  let! search = Search.renderer view_directory ctx in 
	  let! validate_reaction = CMember.Validate.reaction ~ctx ~group in
	
	  O.Box.leaf begin fun input url -> 
	    let columns = List.filter (fun c -> c.MAvatarGrid.Column.show) columns in 
	    let user = ctx # myself |> IIsIn.user in
	    
	    let add = 
	      UrlR.build (ctx # instance)
		O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.entity_id)
		(((),`AddMembers),Some (IEntity.decay $ MEntity.Get.id entity))
	    in
	    
	    let action_list = 
	      let actions = List.map CMoreActions.make [ 
		( `label "member.remove.title" , VIcon.user_delete ,
		  `Do (Js.sendSelected ((UrlMember.rem ()) # build inst group))) ; 
		
		( `label "member.validate.title" , VIcon.tick ,
		  `Do (Js.sendSelected (input # reaction_url validate_reaction))) ;
		
	      ] in
	      VMoreActions.component ~actions ~text:(`label "member.button.selected") ~i18n 
	    in
	    
	    let url  = UrlClient.grid # build inst user list in     

	    let width = 710 - 42 in

	    let edit  = (UrlJoin.edit ()) # build_base inst (MEntity.Get.id entity) in
	    
	    return $ VEntity.List.page
	      ~action_list
	      ~add
	      ~search:(search input) 
	      ~url_csv:(UrlClient.csv # build inst user list)		      
	      ~grid:(fun i18n ctx -> VGrid.render ~width ~url ~cols:columns ~edit ~i18n ctx) 
	      ~i18n   
	  end
	end
      end
      | Some avatar -> begin
	return $ CJoin.Edit.box ~ctx ~entity ~group avatar
      end
  end

  |> O.Box.parse UrlSegs.avatar_id 
    
