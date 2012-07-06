(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

module Grid = MAvatarGrid

module SortFmt = Fmt.Make(struct
  type json t = < asc : bool ; col : int > 
end)

let default_sort = object
  method asc = true
  method col = 0 
end

let max_size = 1000

module RowsFmt = Fmt.Make(struct
  type json t = (string list)
end)

module Render = struct

  let get_field = function
    | `Group (gid,`Field name) ->
      let! group = ohm_req_or (return None) $ MGroup.naked_get gid in  
      let fields = MGroup.Fields.get group in 
      let has_name f = f # name = name in
      return (try Some (List.find has_name fields) with _ -> None)
    | _ -> return None 

  let format_picker json field =       
    match field # edit with 
      | `PickOne  list ->
	let n    = 
	  match json with 
	    | Json.Int i -> i
	    | Json.Array (Json.Int i :: _) -> i
	    | _ -> -1 
	in 
	begin 
	  try let! text = ohm $ TextOrAdlib.to_string (List.nth list n) in
	      return [text] 
	  with _ -> return [] 
	end

      | `PickMany list ->
	let a = try Json.to_list Json.to_int json with _ -> [] in 
	let text n = 
	  try let! text = ohm $ TextOrAdlib.to_string (List.nth list n) in
	      return $ Some text 
	  with _ -> return None
	in
	Run.list_filter text a

      | `LongText
      | `Textarea
      | `Date
      | `Checkbox -> return []

  let empty = return ignore

  let cell url gender field json = function 
    | `Text -> let str = BatOption.default "" (Fmt.String.of_json_safe json) in
	       Asset_Grid_Text.render str
    | `DateTime
    | `Date
    | `Age       -> let! now  = ohmctx (#time) in
		    let! time = req_or empty (Fmt.Float.of_json_safe json) in
		    Asset_Grid_Date.render (time,now)
    | `Status -> let! status = req_or empty (MMembership.Status.of_json_safe json) in		
		 let! key = req_or empty begin match status with 
		   | `NotMember -> None
		   | `Unpaid -> Some (`Unpaid gender)
		   | `Pending -> Some (`Pending gender)
		   | `Invited -> Some (`Invited gender)
		   | `Member -> Some (`GroupMember gender)
		   | `Declined -> Some (`Declined gender)
		 end in
		 Asset_Status_Tag.render key
    | `Checkbox -> let checked = json = Json.Bool true in 
		   Asset_Grid_Checked.render checked
    | `PickOne -> let! field = ohm_req_or empty field in 
		  let! items = ohm $ format_picker json field in 
		  Asset_Grid_Text.render (String.concat ", " items)
    | `Full -> let! info = req_or empty $ MAvatarGridEval.FullProfile.of_json_safe json in
	       Asset_Grid_FullInfo.render (object 
		 method info = info 
		 method url  = url 
	       end)
end 


let () = define UrlClient.Events.def_people begin fun parents entity access -> 
  
  (* What to do if the group is not available ? *)

  let fail = O.Box.fill begin

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = return ignore
    end)

  end in 

  (* Extract the AvatarGrid identifier *)

  let  draft  = MEntity.Get.draft entity in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.list group) in
  let  group = if draft then None else group in   
  let! group = req_or fail group in 

  let  grid  = MGroup.Get.list group in 
  let  lid = Grid.list_id grid in
  
  (* Returning the rows for a given sort *)

  let! sort = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let sort = SortFmt.of_json_safe json in 
    let sort = BatOption.default default_sort sort in

    let! check = ohm $ O.decay (Grid.MyGrid.check_list lid) in

    (* Don't display column-locked lists *)
    match check with Some `ColumnLocked -> return res | _ -> 
    
      let! list = ohm $ O.decay 
	(Grid.MyGrid.read_summary lid 
	   ~sort_column:(sort # col) ~descending:(not (sort # asc))
	   ~count:max_size)
      in
      
      let list = List.map (fun (linid, rev) -> 
	let linid = Id.str $ Grid.MyGrid.LineId.to_id linid in
	let revnum = try fst $ BatString.split rev "-" with _ -> rev in
	Json.String (linid ^ "-" ^ revnum)
      ) list in
      
      return $ Action.json [ "list", Json.Array list ] res

  end in

  (* Returning the data for the given rows *)

  let join_url aid = 
    Action.url UrlClient.Events.join (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ;
	IAvatar.to_string aid ] 
  in
  
  let! rows = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let rows = RowsFmt.of_json_safe json in 
    let rows = BatOption.default [] rows in

    let rows = BatList.filter_map begin fun str -> 
      try let id, _ = BatString.split str "-" in
	  Some (str, Grid.MyGrid.LineId.of_id (Id.of_string id))
      with _ -> None
    end rows in

    let reply list =  
      return $ Action.json [ "list", Json.Object list ] res
    in

    if rows = [] then reply [] else 

      let! get, columns = ohm $ O.decay (Grid.MyGrid.read_lines lid (List.map snd rows)) in

      let to_html_json url json column = 
	let gender = None in
	let field  = O.decay $ Render.get_field column.MAvatarGridColumn.eval in 
	let! html = ohm $ Render.cell url gender field json column.MAvatarGridColumn.view in	
	return $ Json.String (Html.to_html_string html) 
      in

      let! rows = ohm $ Run.list_filter begin fun (str, linid) -> 
	let! line = req_or (return None) $ get linid in 
	let  url  = join_url line.Grid.MyGrid.key in
	try let  cells = BatList.map2 (to_html_json url) line.Grid.MyGrid.cells columns in
	    let! cells = ohm $ Run.list_map identity cells in 
	    return $ Some (str, Json.Array cells)
	with _ -> return None
      end rows in

      reply rows

  end in 

  (* Return the box containing the grid. *)

  O.Box.fill begin 
    
    let! columns = ohm $ O.decay begin 

      let! columns, _, _ = ohm_req_or (return []) $ Grid.MyGrid.get_list lid in

      (* ==== This is some version recovery code that inserts the full-profile if missing *)
      match columns with 
	| { MAvatarGridColumn.eval = `Profile (_, `Full) } :: _ -> return columns
	| other -> begin

	  let columns = List.filter (fun c -> match c.MAvatarGridColumn.eval with 
	    | `Avatar (_,`Name) 
	    | `Profile (_,`Firstname)
	    | `Profile (_,`Lastname)
	    | `Profile (_,`Email) -> false
	    | _ -> true) columns
	  in
	  
	  let columns = MAvatarGridColumn.({
	    eval  = `Profile (IInstance.decay access # iid,`Full) ;
	    label = `text "" ;
	    show  = true ;
	    view  = `Full 
	  }) :: columns in 
	    
	  let! () = ohm $ Grid.MyGrid.set_columns lid columns in

	  return columns

	end 
      (* ==================================== *)

    end in     

    let body = Asset_Grid_Block.render (object
      method columns = List.map MAvatarGridColumn.(fun c -> TextOrAdlib.to_string c.label) columns
      method cols = List.length columns 
      method urlRows = OhmBox.reaction_json rows ()
      method urlSort = OhmBox.reaction_json sort ()
    end) in
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = body
    end)

  end

end
