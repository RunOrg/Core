(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open O
open BatPervasives
open Ohm.Universal

module TheGrid = MAvatarGrid.MyGrid

(* Format an individual cell in the grid output. *)
let format_text html data = 
  try if html 
    then VText.format (VText.head 40 (Json_type.Browse.string data))
    else Json_type.Browse.string data
  with _ -> "" 

let format_datetime html i18n data = 
  try if html 
    then View.write_to_string (VDate.render (Json_type.Browse.float data) i18n)
    else MFmt.date_string (I18n.language i18n) (Json_type.Browse.string data)
  with _ -> ""

let format_status html i18n data = 
  let state = MMembership.Status.of_json_safe data |> BatOption.default `NotMember in
  if html 
  then 
    View.write_to_string (VJoin.Status.render state i18n)
  else 
  let label = match state with
    | `NotMember -> "none"
    | `Pending   -> "to_validate"
    | `Invited   -> "invited"
    | `Unpaid    -> "unpaid"
    | `Declined  -> "denied"
    | `Member    -> "validated"
  in
  I18n.translate i18n (`label ("participate.state." ^ label))

let format_date html i18n data = 
  try let date = MFmt.date_string (I18n.language i18n) in
      date (Json_type.Browse.string data)
  with _ -> ""

let format_checkbox html i18n data = 
  try if html
    then
      if Json_type.Browse.bool data 
      then "<span class='tick'/>" 
      else ""
    else
      if Json_type.Browse.bool data 
      then I18n.translate i18n (`label "yes")
      else I18n.translate i18n (`label "no")
  with _ -> "" 

let format_age data = 
  try match MFmt.float_of_date (Json_type.Browse.string data) with 
    | Some time -> let years = (Unix.time () -. time) /. (365.25 *. 24. *. 3600.) in 
		   string_of_int (int_of_float years)
    | None      -> ""
  with _ -> ""

let format_picker html i18n data field =
  match field # edit with 
    | `pickOne  list ->
      let n    = 
	match data with 
	  | Json_type.Int i -> i
	  | Json_type.Array (Json_type.Int i :: _) -> i
	  | _ -> -1 
      in 
      let text = try I18n.translate i18n (List.nth list n) with _ -> "" in 
      if html 
      then VText.format (VText.head 40 text)
      else text
    | `pickMany list ->
      let a      = try Json_type.Browse.list Json_type.Browse.int data with _ -> [] in 
      let text n = try Some (I18n.translate i18n (List.nth list n)) with _ -> None in
      let text   = String.concat ", " (BatList.filter_map text a) in
      if html 
      then VText.format (VText.head 40 text)
      else text
    | `hide
    | `longtext
    | `textarea
    | `date
    | `checkbox -> ""
      
let get_field = function
  | `Group (gid,`Field name) ->
    let! group = ohm_req_or (return None) $ MGroup.naked_get gid in  
    let fields = MGroup.Fields.get group in 
    let has_name f = f # name = name in
    return (try Some (List.find has_name fields) with _ -> None)
  | _ -> return None 

let format_cell html column field_source i18n data = 
  match MAvatarGrid.Column.(column.view) with 
    | `text     -> return $ format_text     html      data 
    | `datetime -> return $ format_datetime html i18n data 
    | `status   -> return $ format_status   html i18n data
    | `date     -> return $ format_date     html i18n data 
    | `checkbox -> return $ format_checkbox html i18n data
    | `age      -> return $ format_age                data
    | `pickAny  -> let! field = ohm_req_or (return "") field_source in
		   return $ format_picker   html i18n data field

let format_row html columns i18n row = 
  let cells = 
    try let list = 
	  BatList.map2 begin fun column cell -> 
	    match column with 
	      | None                -> None
	      | Some (column,field) -> Some (format_cell html column field i18n cell)
	  end columns row.TheGrid.cells
	in
	BatList.filter_map identity list 
    with _ -> []
  in
  let! printed = ohm $ Run.list_map identity cells in
  return (row, printed)

let format_grid html columns i18n rows = 
  let columns = List.map begin fun column ->
    let field_source = get_field MAvatarGrid.Column.(column.eval) |> Run.memo in
    if not html || MAvatarGrid.Column.(column.show) then
      Some (column, field_source)
    else
      None
  end columns in

  Run.list_map (format_row html columns i18n) rows

(* Grid data retrieval --------------------------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact UrlClient.grid 
  begin fun ctx request response ->

    let i18n = ctx # i18n in
    let fail = Action.javascript Js.panic response in

    (* Extract the list identifier (with read proof) *)
    let! grid  = req_or (return fail) (request # args 0) in
    let  grid  = IAvatarGrid.of_string grid in 
    let! proof = req_or (return fail) (request # args 1) in
    let  user  = IIsIn.user (ctx # myself) in

    let! read  = req_or (return fail) $
      IAvatarGrid.Deduce.from_list_token user grid proof
    in

    let lid = MAvatarGrid.list_id read in 

    (* Extract the query parameters *)
    let start_key = 
      try BatOption.map
	    (fun json -> Json_io.json_of_string ~recursive:true json)
	    (request # post "p") 
      with _ -> None
    and start_docid = 
      BatOption.map (Id.of_string |- TheGrid.LineId.of_id) (request # post "i") 
    in

    let start = match start_key, start_docid with 
      | Some key, Some docid -> Some (key, docid) 
      | _ -> None
    in

    let count = try match request # post "c" with 
      | Some count -> min 50 (max 1 (int_of_string count))
      | None -> 10
      with _ -> 10
    in

    let sort = try match request # post "s" with 
      | Some sort -> int_of_string sort
      | None -> 0
      with _ -> 0
    in

    let descending = try match request # post "o" with 
      | Some "d" -> true
      | _        -> false
      with _ -> false
    in

    (* Check whether the list is currently available *)
    let! status = ohm_req_or (return fail) $ TheGrid.check_list lid in 
    let! () = true_or (return fail) (status <> `ColumnLocked) in

    (* Perform the database query *)
    let! columns, lines, next = ohm $ TheGrid.read lid
      ~sort_column:sort
      ~start
      ~count
      ~descending
    in
    
    (* Format the output *)
    let! formatted = ohm $ format_grid true columns i18n lines in

    let rows = List.map
      (fun (row, list) -> 
	(IAvatar.to_json row.TheGrid.key
	 :: List.map Json_type.Build.string list))
      formatted
    in

    let next = BatOption.map (fun (json,id) -> json, TheGrid.LineId.to_id id) next in
    
    return $ Action.json (Js.Grid.return ~rows ~next) response
      
end

(* Return data as a CSV file ---------------------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact UrlClient.csv
  begin fun ctx request response ->

    let i18n = ctx # i18n in 
    let fail = Action.javascript Js.panic response in

    (* Extract the list identifier (with read proof) *)
    let! grid  = req_or (return fail) (request # args 0) in
    let  grid  = IAvatarGrid.of_string grid in 
    let! proof = req_or (return fail) (request # args 1) in
    let  user  = IIsIn.user (ctx # myself) in

    let! read  = req_or (return fail) $
      IAvatarGrid.Deduce.from_list_token user grid proof
    in

    let lid = MAvatarGrid.list_id read in 

    (* Check whether the list is currently available *)
    let! status = ohm_req_or (return fail) $ TheGrid.check_list lid in 
    let! () = true_or (return fail) (status <> `ColumnLocked) in

    (* Perform the database query *)
    let! columns, lines, _ = ohm $ TheGrid.read lid
      ~sort_column:0
      ~start:None
      ~count:1000
      ~descending:false
    in
    
    (* Format the output *)
    let! formatted = ohm $ format_grid false columns i18n lines in

    let data = OhmCsv.to_csv [] $ List.map snd formatted in
    
    return $ Action.file ~file:"list.csv" ~mime:"text/csv" ~data response
      
  end

(* Check if a list is available or locked --------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact UrlClient.ckgrid
  begin fun ctx request response ->

    let fail     = Action.javascript Js.panic response in
    let res    v = Action.json ["ok", Json_type.Build.bool v] response in

    let! grid  = req_or (return fail) (request # args 0) in
    let  grid  = IAvatarGrid.of_string grid in 
    let! proof = req_or (return fail) (request # args 1) in
    let  user  = IIsIn.user (ctx # myself) in

    let! read  = req_or (return fail) $
      IAvatarGrid.Deduce.from_list_token user grid proof
    in

    let lid = MAvatarGrid.list_id read in 

    (* Check whether the list is currently available *)
    let! status = ohm_req_or (return $ res false) $ TheGrid.check_list lid in 
    return $ res (status <> `ColumnLocked)

  end


