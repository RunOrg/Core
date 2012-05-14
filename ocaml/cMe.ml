(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Network = CMe_network

(* Share settings action -------------------------------------------------------------------- *)

module ShareEdit = struct

  module Fields = FShare.Config.Fields
  module Form   = FShare.Config.Form

  let action ~i18n ~user =
    O.Box.reaction "share-edit" begin fun self bctx (prefix,_) response ->
      
      let form = Form.readpost (bctx # post) in
      
      if Form.not_valid form then 
	return (Action.json (Form.response form) response)
      else begin
	
	let user = IUser.Deduce.is_self user in 
	
	let! update = ohm $ MUser.Share.set user (
	  `basic :: BatList.filter_map (fun item ->
	    let flag = ref false in 
	    ignore (Form.mandatory item Fmt.Bool.fmt flag (i18n,`label "") form) ;
	    if !flag then Some (item :> MFieldShare.t) else None
	  ) Fields.fields
	) in
	
	let code = JsCode.seq [
	  Js.message (I18n.get i18n (`label "changes.saved")) ;
	  Js.redirect (UrlMe.build (bctx # segments) (prefix,`View))
	] in
	
	return (Action.javascript code response) 

      end
    end
end

(* Receive settings action ------------------------------------------------------------------ *)

module ReceiveEdit = struct

  module Fields = FNotification.Receive.Fields
  module Form   = FNotification.Receive.Form

  let action ~i18n ~user =
    O.Box.reaction "receive-edit" begin fun self bctx (prefix,_) response ->
    
      let form = Form.readpost (bctx # post) in
      
      if Form.not_valid form then 
	return (Action.json (Form.response form) response)
      else begin
	
	let user = IUser.Deduce.self_can_edit (IUser.Deduce.is_self user) in 
	let! update = ohm $ MUser.set_notifications user 
	  ~blocked:(
	    BatList.filter_map (fun item ->
	      let checked = ref false in 
	      ignore (Form.mandatory (`Block item) Fmt.Bool.fmt checked (i18n,`label "") form) ;
	      if not !checked then Some (item :> MUser.Notification.t) else None
	    ) Fields.blockable)
	  ~autologin:(
	    let checked = ref false in 
	    ignore (Form.mandatory `Autologin Fmt.Bool.fmt checked (i18n,`label "") form) ;
	    !checked)
	in
	
	let code = JsCode.seq [
	  Js.message (I18n.get i18n (`label "changes.saved")) ;
	  Js.redirect (UrlMe.build (bctx # segments) (prefix,`View))
	] in
	
	return (Action.javascript code response)
      end
    end

end

(* Account edit action --------------------------------------------------------------------- *)

module AccountEdit = struct

  module Fields = FAccount.Edit.Fields
  module Form   = FAccount.Edit.Form

  let action ~i18n ~user = 
    O.Box.reaction "account-edit" begin fun self bctx (prefix,_) response ->
          
      let cuid = ICurrentUser.Deduce.is_unsafe user in 
      
      let firstname = ref ""
      and lastname  = ref ""
      and birthdate = ref None
      and phone     = ref None
      and cellphone = ref None
      and address   = ref None
      and zipcode   = ref None
      and city      = ref None
      and country   = ref None
      and gender    = ref None
      and picture   = ref None
      in
      
      let date_fmt = MFmt.date (I18n.language i18n) in
      
      let form = Form.readpost (bctx # post)
        |> Form.mandatory `Firstname Fmt.String.fmt   firstname (i18n,`label "member.create.firstname.required")
	|> Form.mandatory `Lastname  Fmt.String.fmt   lastname  (i18n,`label "member.create.lastname.required")
	|> Form.optional  `Pic       (CFile.get_pic_fmt cuid) picture
	|> Form.optional  `Birthdate date_fmt     birthdate
	|> Form.optional  `Address   Fmt.String.fmt   address
	|> Form.optional  `City      Fmt.String.fmt   city
	|> Form.optional  `Zipcode   Fmt.String.fmt   zipcode
	|> Form.optional  `Country   Fmt.String.fmt   country
	|> Form.optional  `Phone     Fmt.String.fmt   phone
	|> Form.optional  `Cellphone Fmt.String.fmt   cellphone
	|> Form.optional  `Gender    MFmt.Gender.fmt gender
      in      
      
      if Form.not_valid form then 
	return (Action.json (Form.response form) response)
      else begin
	
	let user = IUser.Deduce.is_self user in 
	let! update = ohm $ MUser.update (IUser.Deduce.self_can_edit user) (object
	  method firstname = !firstname
	  method lastname  = !lastname
	  method email     = ""
	  method birthdate = !birthdate
	  method address   = !address
	  method city      = !city
	  method zipcode   = !zipcode
	  method country   = !country
	  method phone     = !phone
	  method cellphone = !cellphone
	  method picture   = !picture
	  method gender    = !gender
	  method white     = None
	end) in
	
	let code = JsCode.seq [
	  Js.message (I18n.get i18n (`label "changes.saved")) ;
	  Js.redirect (UrlMe.build (bctx # segments) (prefix,`View))
	] in
	
	return (Action.javascript code response)
	    
      end
    end
end

module Boxes = struct
    
  (* Account ------------------------------------------------------------------------------- *)

  let account ~i18n ~user = 

    let cuid = ICurrentUser.Deduce.is_unsafe user in 

    let view ~i18n = 
      O.Box.leaf begin fun _ _ -> 

	let! data = ohm_req_or (return identity) $ 
	  MUser.get (IUser.Deduce.self_can_view (IUser.Deduce.is_self user)) in 
	
	let! picture = ohm $ CPicture.large (data # picture) in

	return $ VMe.Account.view ~user:data ~picture ~i18n
	       	  
      end
    in

    let password ~i18n =
      O.Box.leaf begin fun _ _ -> 
	return (
	  VMe.Account.set_password 
	    ~url:(UrlMe.setpass # build)
	    ~init:FAccount.Password.Form.empty
	    ~i18n
	)
      end      
    in

    let edit ~i18n = 
      let! edit = AccountEdit.action ~user ~i18n in 
      O.Box.leaf begin fun bctx (prefix,_) -> 

	let! data = ohm_req_or (return identity) $ 
	  MUser.get (IUser.Deduce.self_can_view (IUser.Deduce.is_self user)) in

	let date_fmt = MFmt.date (I18n.language i18n) in
	let form_init = 
	  let str = Json_type.Build.string and opt = Json_type.Build.optional in
	  FAccount.Edit.Form.initialize begin function
	    | `Firstname -> opt str (data # firstname)
	    | `Lastname  -> opt str (data # lastname) 
	    | `Birthdate -> opt (date_fmt.Fmt.to_json) (data # birthdate)
	    | `Phone     -> opt str (data # phone)
	    | `Cellphone -> opt str (data # cellphone)
	    | `Address   -> opt str (data # address)
	    | `Zipcode   -> opt str (data # zipcode) 
	    | `City      -> opt str (data # city) 
	    | `Country   -> opt str (data # country) 
	    | `Gender    -> opt (MFmt.Gender.to_json) (data # gender) 
	    | `Pic       -> opt ((CFile.get_pic_fmt cuid).Fmt.to_json) (data # picture)
	  end 
	in
	  
	return $ VMe.Account.edit 
	  ~uploader:CFile.pic_uploader
	  ~gender:CGender.picker
	  ~form_url:(bctx # reaction_url edit) 
	  ~cancel:(UrlMe.build (bctx # segments) (prefix,`View)) 
	  ~form_init
	  ~email:(data # email)
	  ~i18n
	
      end
    in

    let share ~i18n = 
      let! share_reaction = ShareEdit.action ~user ~i18n in
      O.Box.leaf
	begin fun bctx (prefix,_) -> 
	 
	  let! data = ohm_req_or (return identity) $ 
	    MUser.get (IUser.Deduce.self_can_view (IUser.Deduce.is_self user)) in
	  
	  let share = data # share in 
	  let form_init = 		
	    FShare.Config.Form.initialize begin fun item ->
	      Json_type.Build.bool (List.mem (item :> MFieldShare.t) share)
	    end 
	  in
	  
	  return $ VMe.Account.share 
	    ~form_url:(bctx # reaction_url share_reaction) 
	    ~cancel:(UrlMe.build (bctx # segments) (prefix,`View)) 
	    ~form_init
	    ~i18n
	    
	end
    in

    let receive ~i18n = 
      let! receive = ReceiveEdit.action ~user ~i18n in
      O.Box.leaf
	begin fun bctx (prefix,_) -> 	  
	  let! data = ohm_req_or (return identity) $ 
	    MUser.get (IUser.Deduce.self_can_view (IUser.Deduce.is_self user)) in
	  
	  let blocked = data # blocktype in 
	  let form_init = 
	    FNotification.Receive.Form.initialize begin function
	      | `Block item ->
		Json_type.Build.bool (not (List.mem (item :> MUser.Notification.t) blocked))
	      | `Autologin -> 
		Json_type.Build.bool (data # autologin)
	    end 
	  in
	  
	  return $ VMe.Account.receive
	    ~form_url:(bctx # reaction_url receive) 
	    ~cancel:(UrlMe.build (bctx # segments) (prefix,`View)) 
	    ~form_init
	    ~i18n
	
	end
     
    in
    
    let tabs ~i18n = 
      CTabs.box 
	~list:[ CTabs.fixed `View      (`label "me.account.tab.view")     (lazy (view i18n)) ;
		CTabs.fixed `Edit      (`label "me.account.tab.edit")     (lazy (edit i18n)) ;
		CTabs.fixed `Password  (`label "me.account.tab.password") (lazy (password i18n)) ;
		CTabs.fixed `Share     (`label "me.account.tab.privacy")  (lazy (share i18n)) ;
		CTabs.fixed `Receive   (`label "me.account.tab.receive")  (lazy (receive i18n))
	      ]
	~url:(UrlMe.build)
	~default:`View
	~seg:CSegs.me_account_tabs
	~i18n
    in
    let content = "content" in
    O.Box.node 
      (fun input _ -> 
	return [content,tabs ~i18n], 
	return (VMe.Account.full ~box:(input # name,content) ~i18n))
      
  (* Messages (none, actually) ----------------------------------------------------------- *)

  let messages ~i18n ~user = 
    O.Box.leaf
      (fun input _ -> return (VMessage.not_yet ~i18n))

  (* Main -------------------------------------------------------------------------------- *)

  let main ~i18n ~user = 

    O.Box.decide begin fun _ url -> 
      return (
	match url with 
	  | _, `Account  -> account           ~i18n ~user
	  | _, `Network  -> Network.box       ~i18n ~user 
	  | _, `News     -> CNews.box         ~i18n ~user
	  | _, `Messages -> messages          ~i18n ~user
      )
    end
    |> O.Box.parse CSegs.me_pages
   
end

let () = CCore.User.register_ajax UrlMe.me_ajax begin fun i18n user request response -> 

  match request # post "same" with 
      
    | None -> 
      
      O.Box.on_reaction 
	(Boxes.main ~i18n ~user) UrlMe.builder (request :> Box.source) response
	
    | Some string -> 
      
      let same = 
	try 
	  let json = Json_io.json_of_string string in
	  let list = Json_type.Browse.list Json_type.Browse.int json in
	  List.sort compare list
	with _ -> []
      in
      
      O.Box.on_update 
	(Boxes.main ~i18n ~user) UrlMe.builder (request :> Box.source) same response

end

(* Password set action --------------------------------------------------------------------- *)

module SetPassword = struct

  module Fields = FAccount.Password.Fields
  module Form   = FAccount.Password.Form

  let () = CCore.User.register UrlMe.setpass begin fun i18n cuid request response ->

    let pass       = ref "" 
    and pass2      = ref ""
    in
    
    let form = Form.readpost (request # post)
      |> Form.mandatory `Pass       Fmt.String.fmt pass       (i18n,`label "login.signup-form.pass.required")
      |> Form.mandatory `Pass2      Fmt.String.fmt pass2      (i18n,`label "login.signup-form.pass2.required")
    in 
    
    if Form.not_valid form then return (Action.json (Form.response form) response) else      
      if !pass <> !pass2 then
	return
	  (Action.json (Form.response (Form.error `Pass2 (i18n,`label "login.signup-form.pass2.invalid") form)) response)
      else
	
	let user = IUser.Deduce.is_self cuid in     
	
	let message = I18n.get i18n (`label "changes.saved") in
	
	let! () = ohm $ MUser.set_password !pass user in
	return (Action.javascript (Js.message message) response)
	  
  end
    
end

    
(* Index action ---------------------------------------------------------------------------- *)

let () = CCore.User.register UrlMe.me begin fun i18n cuid request response ->

  let title = return (I18n.get i18n (`label "me.title")) in
  
  let no_user = Action.redirect (UrlLogin.index # build) response in
  
  let! user = ohm_req_or (return no_user) $
    MUser.get (cuid |> IUser.Deduce.is_self |> IUser.Deduce.self_can_view)
  in
  
  let body  = return (VMe.Index.render (user # white = None) i18n) in 

  let user_name = user # fullname in 
  
  let! count = ohm $ MNotification.count cuid in
  let! message_count = ohm $ MMessage.total_count (IUser.Deduce.is_self cuid) in
  
  let js_files  = ["/public/js/jquery-address.min.js"] in
  
  let js        = JsCode.seq [ 
    JsBase.init (UrlMe.build Box.Seg.(root ++ CSegs.me_pages) ((),`Account));
    Js.init
  ] in

  let! white = ohm $ Run.opt_bind MWhite.get (user # white) in
  let  name  = match white with 
    | None       -> "RUN<strong>ORG</strong>"
    | Some white -> MWhite.name white
  in

  let theme  = BatOption.map (fun w -> MWhite.theme w, `White) white in

  let navbar    = CCore.navbar name cuid user_name None count message_count i18n in
  
  CCore.render ?theme ~navbar ~js_files ~js ~title ~body response
end
  

