(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Grid    = MAvatarGrid
module Render  = CGrid_render
module Columns = CGrid_columns

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

let box access gid fail cols_url invite_url join_url wrapper = 

  let actor = access # actor in 

  (* Extract the AvatarGrid identifier *)

  let! group = ohm $ O.decay (MAvatarSet.try_get actor gid) in
  let! group = ohm $ O.decay (Run.opt_bind MAvatarSet.Can.list group) in
  let! group = req_or fail group in 

  let  grid  = MAvatarSet.Get.list group in 
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

  (* Starting an export *)
  let! export = O.Box.react Fmt.Unit.fmt begin fun () _ _ res ->
    let! exid = ohm $ O.decay (CAvatarExport.start (MAvatarSet.Get.id group)) in 
    let  url  = CExport.status_url access exid in 
    return $ Action.json 
      [ "url", JsCode.Endpoint.to_json (JsCode.Endpoint.of_url url) ] res
  end in 

  (* Returning the data for the given rows *)
  
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
	    view  = `Full 
	  }) :: columns in 
	    
	  let! () = ohm $ Grid.MyGrid.set_columns lid columns in

	  return columns

	end 
      (* ==================================== *)

    end in     
	     
    let body = Asset_Grid_Block.render (object
      method invite  = invite_url 
      method coledit = cols_url 
      method columns = List.map MAvatarGridColumn.(fun c -> TextOrAdlib.to_string c.label) columns
      method cols = List.length columns 
      method urlExport = JsCode.Endpoint.to_json 
	(OhmBox.reaction_endpoint export ())
      method urlRows = OhmBox.reaction_json rows ()
      method urlSort = OhmBox.reaction_json sort ()
    end) in
    
    wrapper body 
      
  end
    
