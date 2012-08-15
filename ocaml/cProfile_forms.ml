(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module F = MProfileForm

module HiddenFmt = Fmt.Bool

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

let template iscomm fields = 

  OhmForm.begin_object (fun ~name ~data ~hidden -> (object
    method name = name
    method data = data
    method hidde = hidden 
  end))

  |> OhmForm.append (fun f name -> return $ f ~name) 
      (if iscomm then 
	  VEliteForm.rich 
	    ~label:(AdLib.get `Profile_Form_Edit_Comment)
	    (fun seed -> return $ seed # name)
	    (OhmForm.required (AdLib.get `Profile_Form_Edit_Required))
       else 
	  VEliteForm.text
	    ~label:(AdLib.get `Profile_Form_Edit_Title)
	    (fun seed -> return $ seed # name)
	    (OhmForm.required (AdLib.get `Profile_Form_Edit_Required)))
	  	  
  |> OhmForm.append (fun f data -> return $ f ~data) begin
    List.fold_left (fun acc field -> 
      acc |> OhmForm.append (fun json result -> return $ (field # name,result) :: json)
	  begin match field # edit with 
	    | `Checkbox
	    | `Date
	    | `LongText
	    | `PickMany _ 
	    | `PickOne  _ 
	    | `Textarea ->
	      (VEliteForm.textarea 
		 ~label:(AdLib.get (field # label))
		 (fun seed -> return begin 
		   try Json.to_string (List.assoc (field # name) (seed # data))
		   with _ -> ""
		 end)
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

let newForm aid kind access render =

  let fields = PreConfig_ProfileForm.fields kind in
  let iscomm = PreConfig_ProfileForm.comment kind in
 
  let! post = O.Box.react Fmt.Unit.fmt begin fun _ _ _ res -> return res end in 

  let form = OhmForm.create ~template:(template iscomm fields) ~source:(OhmForm.empty) in
  let url  = OhmBox.reaction_endpoint post () in

  render (Asset_Profile_FormEdit.render (OhmForm.render form url))
  
let () = CClient.define UrlClient.Profile.def_newForm begin fun access ->

  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let! aid = O.Box.parse IAvatar.seg in
  let! iid = ohm_req_or e404 $ O.decay (MAvatar.get_instance aid) in 
  let! ()  = true_or e404 (iid = IInstance.decay (access # iid)) in 

  let render body = 
    O.Box.fill $ O.decay begin 
      
      let! name = ohm $ CAvatar.name aid in 
      
      Asset_Admin_Page.render (object
	method parents = [ (object
	  method title = CAvatar.name aid 
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

let body access aid me = 

  let create = 
    if CAccess.admin access = None then None else 
      Some (Action.url UrlClient.Profile.newForm (access # instance # key)
	      [ IAvatar.to_string aid ] ) 
  in

  Asset_Profile_Forms.render (object
    method create = create
    method list = []
  end)

