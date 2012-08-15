(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module F = MProfileForm

(* Selecting the kind of profile form to be created ================================================ *)

let selectKind aid kinds access render =       

  let list = List.map begin fun pfkid -> (object
    method url      = Action.url UrlClient.Profile.newForm (access # instance # key)
      [ IAvatar.to_string aid ; IProfileForm.Kind.to_string pfkid ]
    method name     = PreConfig_ProfileForm.name pfkid
    method subtitle = PreConfig_ProfileForm.subtitle pfkid 
  end) end kinds in 
  
  let body = Asset_Profile_FormPickKind.render (object
    method list = list
  end) in

  render body 

(* The form template for creating/editing profile forms ============================================ *)

module HiddenFmt = Fmt.Bool

let template iscomm fields = 

  OhmForm.begin_object (fun ~name ~data ~hidden -> (object
    method name   = name
    method data   = data
    method hidden = hidden 
  end))

  |> OhmForm.append (fun f name -> return $ f ~name) 
      (if iscomm then 
	  VEliteForm.rich 
	    ~label:(AdLib.get `Profile_Form_Edit_Comment)
	    (fun seed -> return $ Html.to_html_string (MRich.OrText.to_html (seed # name)))
	    (fun field text -> let text = BatString.strip text in 
			       if text = "" then 
				 let! error = ohm $ AdLib.get `Profile_Form_Edit_Required in
				 return $ Bad (field,error)
			       else 
				 return $ Ok (`Rich (MRich.parse text)))
       else 
	  VEliteForm.text
	    ~label:(AdLib.get `Profile_Form_Edit_Title)
	    (fun seed -> return $ MRich.OrText.to_text (seed # name))
	    (fun field text -> let text = BatString.strip text in 
			       if text = "" then
				 let! error = ohm $ AdLib.get `Profile_Form_Edit_Required in 
				 return $ Bad (field,error)
			       else
				 return $ Ok (`Text text)))
	  	  
  |> OhmForm.append (fun f data -> return $ f ~data) begin
    List.fold_left (fun acc field -> 
      acc |> OhmForm.append (fun json result -> return $ (field # name,result) :: json)
	  begin let label = AdLib.get (field # label) in 
		let json seed = List.assoc (field # name) (seed # data) in 
		match field # edit with 
		  | `LongText -> 
		    (VEliteForm.text ~label
		       (fun seed -> return (try Json.to_string (json seed) with _ -> ""))
		       (fun field data -> return $ Ok (Json.String data))) 
		  | `Date ->
		    (VEliteForm.date ~label
		       (fun seed -> return (try Json.to_string (json seed) with _ -> ""))
		       (fun field data -> return $ Ok (Json.String data)))
		  | `PickOne  list -> 
		    (VEliteForm.radio ~label
		       ~format:Fmt.Int.fmt
		       ~source:(BatList.mapi (fun i label -> i, AdLib.write label) list)
		       (fun seed -> return (try Some (Json.to_int (json seed)) with _ -> None))
		       (fun field data -> return $ Ok (Json.of_opt Json.of_int data)))
		  | `PickMany list ->
		    (VEliteForm.checkboxes ~label
		       ~format:Fmt.Int.fmt
		       ~source:(BatList.mapi (fun i label -> i, AdLib.write label) list)
		       (fun seed -> return (try Json.to_list Json.to_int (json seed) with _ -> []))
		       (fun field data -> return $ Ok (Json.of_list Json.of_int data)))
		  | `Checkbox ->
		    (VEliteForm.checkboxes ~label
		       ~format:Fmt.Unit.fmt
		       ~source:[ (), return ignore ]
		       (fun seed -> return (try if Json.to_bool (json seed) then [()] else [] with _ -> []))
		       (fun field data -> return $ Ok (Json.Bool (data <> []))))
		  | `Textarea ->
		    (VEliteForm.textarea ~label
		       (fun seed -> return (try Json.to_string (json seed) with _ -> ""))
		       (fun field data -> return $ Ok (Json.String data))) 
	  end 
    ) (OhmForm.begin_object []) fields
  end

  |> OhmForm.append (fun f hidden -> return $ f ~hidden) 
      (VEliteForm.radio 
	 ~label:(AdLib.get `Profile_Form_Edit_Hidden)
	 ~format:HiddenFmt.fmt
	 ~source:[
	   true, Asset_Profile_StatusRadio.render (object
	     method status = Some `Secret
	     method label  = AdLib.get (`Profile_Form_Edit_Hidden_Label true)
	   end) ;
	   false, Asset_Profile_StatusRadio.render (object
	     method status = None
	     method label  = AdLib.get (`Profile_Form_Edit_Hidden_Label false)
	   end) ]
	 (fun seed -> return $ Some (seed # hidden))
	 (fun field hidden_opt -> match hidden_opt with 
	   | Some hidden -> return $ Ok hidden 
	   | None -> let! error = ohm $ AdLib.get `Profile_Form_Edit_Required in 
		     return $ Bad (field,error)))

  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Profile_Form_Edit_Save)

(* Creating a new profile form of a selected kind ================================================== *)

let newForm aid kind access render =

  let fields = PreConfig_ProfileForm.fields kind in
  let iscomm = PreConfig_ProfileForm.comment kind in
 
  let template = template iscomm fields in 

  let! post = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 

    let  src  = OhmForm.from_post_json json in 
    let  form = OhmForm.create ~template ~source:src in

    (* Extract the result for the form *)
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  

    (* Save the changes to the database *)
    let! pfid = ohm $ O.decay (MProfileForm.create access aid 
			      ~kind
			      ~hidden:(result # hidden) 
			      ~name:(result # name) 
			      ~data:(result # data))
    in
    
    (* Redirect to main page *)

    let url = 
      Action.url UrlClient.Profile.home (access # instance # key) 
	[ IAvatar.to_string aid ; fst UrlClient.Profile.tabs `Forms ; IProfileForm.to_string pfid ] 
    in  
 
    return $ Action.javascript (Js.redirect url ()) res

  end in 

  let form = OhmForm.create ~template ~source:(OhmForm.empty) in
  let url  = OhmBox.reaction_endpoint post () in

  render (Asset_Profile_FormEdit.render (OhmForm.render form url))
  
(* Entire creation process for profile forms ======================================================= *)

let () = CClient.define UrlClient.Profile.def_newForm begin fun access ->

  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let! access = req_or e404 (CAccess.admin access) in 
  let! aid = O.Box.parse IAvatar.seg in
  let! iid = ohm_req_or e404 $ O.decay (MAvatar.get_instance aid) in 
  let! ()  = true_or e404 (iid = IInstance.decay (access # iid)) in 

  let render body = 
    O.Box.fill begin 
      
      let! name = ohm $ O.decay (CAvatar.name aid) in 
      
      Asset_Admin_Page.render (object
	method parents = [ (object
	  method title = return name
	  method url   = Action.url UrlClient.Profile.home (access # instance # key) 
	    [ IAvatar.to_string aid ; fst UrlClient.Profile.tabs `Forms ]
	end) ]
	method here  = AdLib.get `Profile_Forms_Create
	method body  = body
      end)
	
    end
  in

  let kinds = PreConfig_Vertical.profileForms (access # instance # ver) in

  let! kind = O.Box.parse OhmBox.Seg.string in 
  let  kind =
    match IProfileForm.Kind.of_string kind with Some kind -> Some kind | None ->
      match kinds with [kind] -> Some kind | _ -> None
  in

  match kind with 
    | Some kind -> newForm aid kind access render
    | None when kinds = [] -> e404
    | None -> selectKind aid kinds access render

end

(* Listing available profile forms ================================================================= *)

let body access aid me render = 

  let! pfid = O.Box.parse IProfileForm.seg in 
  let! item = ohm $ O.decay (MProfileForm.access pfid access) in

  (* When the requested item is not available, draw the list of items *)

  let no_item = O.Box.fill $ O.decay begin 
    
    let! list = ohm begin
      match CAccess.admin access with 
	| Some access -> let! list = ohm $ MProfileForm.All.by_avatar aid access in
			 return $ List.map (fun (id,info) -> IProfileForm.decay id, info) list
	| None when me -> let! list = ohm $ MProfileForm.All.mine access in
			  return $ List.map (fun (id,info) -> IProfileForm.decay id, info) list
	| None -> return []
    end in     
    
    let create = 
      if CAccess.admin access = None then None else 
	Some (Action.url UrlClient.Profile.newForm (access # instance # key)
		[ IAvatar.to_string aid ] ) 
    in
    
    let! list = ohm $ Run.list_filter begin fun (id,info) ->
      
      let url = 
	Action.url UrlClient.Profile.home (access # instance # key) 
	  [ IAvatar.to_string aid ; fst UrlClient.Profile.tabs `Forms ; IProfileForm.to_string id ]
      in
      
      let  time, author = BatOption.default info.MProfileForm.Info.created info.MProfileForm.Info.updated in     
      let! author = ohm $ CAvatar.mini_profile author in
      let! now = ohmctx (#time) in
      
      let  text = OhmText.cut ~ellipsis:"…" 100 $ MRich.OrText.to_text info.MProfileForm.Info.name in   
      
      return $ Some (object
	method url = url
	method author = author
	method time = (time,now)
	method name = text
	method kind = PreConfig_ProfileForm.name info.MProfileForm.Info.kind 
	method hidden = info.MProfileForm.Info.hidden 
      end)
	
    end list in
    
    render $ Asset_Profile_Forms.render (object
      method create = create
      method list = list
    end)
      
  end in
  
  (* Check whether the item exists and belongs to the avatar *)

  let! edit, pfid, info, data = ohm_req_or no_item $ O.decay begin match item with 
    | `None -> return None
    | `View pfid -> let! info = ohm_req_or (return None) $ MProfileForm.get pfid in
		    let! data = ohm $ MProfileForm.get_data pfid in 
		    return $ Some (false, IProfileForm.decay pfid, info, data) 
    | `Edit pfid -> let! info = ohm_req_or (return None) $ MProfileForm.get pfid in
		    let! data = ohm $ MProfileForm.get_data pfid in 
		    return $ Some (true, IProfileForm.decay pfid, info, data) 
  end in 

  let! () = true_or no_item (info.MProfileForm.Info.aid = aid) in

  (* Draw the individual form *)
    
  let fields = BatList.filter_map begin fun field ->
    try let data  = List.assoc (field # name) data in
	let label = AdLib.write (field # label) in
	let value = match field # edit with 
	  | `Textarea
	  | `LongText -> 
	    let text = Json.to_string data in 
	    Asset_Profile_Form_Text.render text
	  | `Date ->
	    let date = Json.to_string data in 
	    let t = match MFmt.float_of_date date with Some x -> x | None -> raise Not_found in
	    Asset_Profile_Form_Date.render t 
	  | `PickOne  list -> 	    
	    let pick = Json.to_int data in
	    let text = AdLib.write (List.nth list pick) in
	    Asset_Profile_Form_Pick.render [text]
	  | `PickMany list ->
	    let picks = Json.to_list Json.to_int data in 
	    let texts = List.map (fun i -> AdLib.write (List.nth list i)) picks in
	    Asset_Profile_Form_Pick.render texts
	  | `Checkbox ->
	    let checked = data = Json.Bool true in
	    Asset_Profile_Form_Checkbox.render checked
	in
	Some (object
	  method label = label
	  method value = value
	end)
    with _ -> None
  end (PreConfig_ProfileForm.fields info.MProfileForm.Info.kind) in

  let data = object
    method back = Action.url UrlClient.Profile.home (access # instance # key) 
      [ IAvatar.to_string aid ; fst UrlClient.Profile.tabs `Forms ]
    method edit = if edit then 
	Some (Action.url UrlClient.Profile.editForm (access # instance # key) 
		[ IProfileForm.to_string pfid ])
      else None
    method body = MRich.OrText.to_html info.MProfileForm.Info.name 
    method fields = fields
  end in

  O.Box.fill $ O.decay (render (Asset_Profile_Form.render data))
