(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CWebsite_admin_common

let template : (O.BoxCtx.t,'a,'b) OhmForm.template = 

  OhmForm.begin_object (fun ~name ~desc ~tags ~address ~facebook ~twitter ~website -> (object
    method name = name
    method desc = desc
    method tags = tags
    method address = address
    method facebook = facebook
    method twitter = twitter
    method website = website
  end))
    
  |> OhmForm.append (fun f name -> return $ f ~name) 
      (VEliteForm.text     
	 ~label:(AdLib.get `Website_Admin_About_Name)
	 (fun p -> return $ p # name)
	 OhmForm.keep)

  |> OhmForm.append (fun f desc -> return $ f ~desc)
      (VEliteForm.rich     
	 ~label:(AdLib.get `Website_Admin_About_Description)
	 (fun p -> match p # desc with 
	   | None      -> return "" 
	   | Some rich -> return (Html.to_html_string (MRich.OrText.to_html rich)))
	 OhmForm.keep)

  |> OhmForm.append (fun f tags -> return $ f ~tags)
      (VEliteForm.text     
	 ~label:(AdLib.get `Website_Admin_About_Tags)
	 ~detail:(AdLib.get `Website_Admin_About_Tags_Detail)
	 (fun p -> return (String.concat ", " (List.map String.lowercase p # tags)))
	 OhmForm.keep)     

  |> OhmForm.append (fun f address -> return $ f ~address)
      (VEliteForm.text     
	 ~label:(AdLib.get `Website_Admin_About_Address)
	 (fun p -> return $ BatOption.default "" p # address)
	 OhmForm.keep)     

  |> OhmForm.append (fun f facebook -> return $ f ~facebook)
      (VEliteForm.text     
	 ~label:(AdLib.get `Website_Admin_About_Facebook)
	 (fun p -> return $ BatOption.default "" p # facebook)
	 OhmForm.keep)     

  |> OhmForm.append (fun f twitter -> return $ f ~twitter)
      (VEliteForm.text     
	 ~label:(AdLib.get `Website_Admin_About_Twitter)
	 (fun p -> return $ BatOption.default "" p # twitter)
	 OhmForm.keep)     

  |> OhmForm.append (fun f website -> return $ f ~website)
      (VEliteForm.text     
	 ~label:(AdLib.get `Website_Admin_About_Website)
	 (fun p -> return $ BatOption.default "" p # site)
	 OhmForm.keep)     

  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Website_Admin_About_Submit) 

let _ = CClient.define_admin UrlClient.Website.def_about begin fun access -> 

  let empty = O.Box.fill (return ignore) in

  let! profile = ohm_req_or empty $ O.decay (MInstance.Profile.get (access # iid)) in

  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let  src  = OhmForm.from_post_json json in 
    let  form = OhmForm.create ~template ~source:src in
        
    (* Extract the result for the form *)
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  

    let tags = 
      let source = result # tags in
      let regex  = Str.regexp "[ ,.;]+" in
      Str.split regex source
    in

    let! () = ohm $ O.decay begin MInstance.update (access # iid) 
	~name:(result # name)
	~desc:(let rich = MRich.parse (result # desc) in 
	       if MRich.length rich = 0 then None else Some (`Rich rich))
	~address:(let a = BatString.strip result # address in
		  if a = "" then None else Some a) 
	~site:(let w = BatString.strip result # website in
	       if w = "" then None else Some w)
	~contact:None 
	~phone:None
	~facebook:(let f = BatString.strip result # facebook in
		   if f = "" then None else Some f)
	~twitter:(let t = BatString.strip result # twitter in
		  if t = "" then None else Some t)
	~tags
    end in
	
    (* Return to main page *) 

    let url = Action.url UrlClient.about (access # instance # key) () in
    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill begin

    let form = OhmForm.create ~template ~source:(OhmForm.from_seed profile) in
    let url  = OhmBox.reaction_endpoint save () in

    wrap access `Website_Admin_About_Edit
      (Asset_EliteForm_Form.render (OhmForm.render form url))

  end 

end 

