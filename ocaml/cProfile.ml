(* © 2012 RunOrvg *)

open Ohm
open BatPervasives
open O
open Ohm.Universal

module DetailsFeed = struct

  let more_arg  = "t"

  let get ~ctx ~id ~url ~empty start = 
    
    let cache = CFeed.make_cache ctx in
    let avatar = id in 
    let! feed, next = ohm $ MNews.List.by_avatar ~ctx ~avatar start in
    let! feed = ohm $ Run.list_filter (CFeed.render cache) feed in
    
    let next = next |> BatOption.map begin fun next -> 
      Js.More.fetch ~args:[ more_arg, Json_type.Build.float next ] url
    end in
    
    return begin 
      if feed = [] then empty (ctx # i18n) else
	VFeed.more ~feed ~next ~i18n:(ctx # i18n)
    end
          
  let more ~ctx ~id = 

    O.Box.reaction "feed-more" begin fun self bctx url response ->
  
      let respond html = Action.json (Js.More.return html) response in 
      let fail = respond identity in
      
      let start = 
	try BatOption.map float_of_string (bctx # post more_arg) 
	with _ -> None
      in

      let url = bctx # reaction_url self in

      if BatOption.is_some start then            
	get ~ctx ~id ~url ~empty:(fun i c -> c) start |> Run.map respond
      else
	return fail

    end

end

module SendMessage = struct

  let form_name = "send-message-form"
  let post_name = "send-message-post"

  module Form = FProfile.SendMessage.Form

  let post ~ctx ~id = 
    O.Box.reaction "send-message-post" begin fun self bctx url response ->
    
      let title = ref "" 
      and body  = ref "" in
      
      let form = Form.readpost (bctx # post) 
        |> Form.mandatory `Title Fmt.String.fmt title (ctx # i18n, `label "messages.create-form.title.required")
        |> Form.mandatory `Body  Fmt.String.fmt body  (ctx # i18n, `label "messages.create-form.body.required")
      in

      if Form.not_valid form then return (Action.json (Form.response form) response) else
	
	let! mid = ohm $ MMessage.create_and_post
	  ~ctx
	  ~title:(!title)
	  ~invited:[id]
	  ~post:(!body)	
	in	 
	
	let js = Js.redirect (UrlMessage.build (ctx # instance) mid) in      
	return $ Action.javascript (JsCode.seq [ Js.Dialog.close ; js ]) response
	    
    end

  let form ~ctx ~post = 
    O.Box.reaction "send-message-form" begin fun self bctx url response ->
    
      let body = 
	VProfile.send_message
	  ~url:(bctx # reaction_url post) 
	  ~init:Form.empty
	  ~i18n:(ctx # i18n)
      in
      
      let title = I18n.translate (ctx # i18n) (`label "profile.send-message") in
      
      return (Action.javascript (Js.Dialog.create body title) response)

    end

  let reaction ~ctx ~id callback = 
    let! post = post ~ctx ~id in
    let! form = form ~ctx ~post in
    callback form

end

let with_profile_details ctx id f = 

  let! details = ohm $ MAvatar.details id in

  let! data_opt = ohm begin 
    let  nil     = return None in 
    let! user    = req_or nil (details # who) in
    let! admin   = req_or nil (ctx # myself |> IIsIn.Deduce.is_admin) in 
    let  view    = IIsIn.instance admin |> IInstance.Deduce.admin_view_profile in
    let! profile = ohm_req_or nil $ MProfile.find_view view user in
    let! _, data = ohm_req_or nil $ MProfile.data profile in
    return (Some data)
  end in

  f details data_opt

let box_details ~ctx ~id = 
  let i18n = ctx # i18n in

  let! send_message = SendMessage.reaction ~ctx ~id in
  let! more = DetailsFeed.more ~ctx ~id in

  O.Box.leaf begin fun bctx url ->

    with_profile_details ctx id begin fun details profile -> 

      let name    = CName.get i18n details in
      let status  = ctx # status (match details # status with None -> `Contact | Some s -> s) in
      let actions = if BatOption.map IAvatar.decay ctx # self_if_exists <> Some id then
	  [
	    `label "profile.send-message" , VIcon.email_go ,
	    Js.runFromServer (bctx # reaction_url send_message) 
	  ]
	else []
      in

      let url = bctx # reaction_url more in

      let! url_pic = ohm $ CPicture.large (details # picture) in
      let! feed = ohm $ DetailsFeed.get ~ctx ~id ~url ~empty:VProfile.empty None in
	  
      return $ VProfile.page
	~url_asso:(UrlR.home # build ctx # instance) 
	~asso:(ctx # instance # name)
	~url_above:(UrlDirectory.home # build ctx # instance)
	~url_pic
	~feed
	~profile
	~name
	~status
	~actions:(CActionList.make actions)
	~i18n
	
    end
  end

let box ~ctx = 
  let i18n = ctx # i18n in 
  O.Box.decide begin fun _ (_,id) -> 
    let box = 
      match IIsIn.Deduce.is_token (ctx # myself) with None -> None | Some isin -> 
	let ctx = CContext.evolve_full isin ctx in 
	match id with None -> None | Some id -> Some (box_details ~ctx ~id)
    in
    return (
      match box with 
	| None     -> O.Box.leaf (fun _ _ -> return $ VForbidden.render i18n)
	| Some box -> box
    )
  end
  |> O.Box.parse CSegs.avatar_id
    
