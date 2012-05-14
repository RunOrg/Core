(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Display the box ------------------------------------------------------------------------- *)

let info_box ~(ctx:'any CContext.full) = 
  let i18n = ctx # i18n in 

  O.Box.leaf  
    begin fun input _ -> 

      let cuid = IIsIn.user (ctx # myself) in 

      let! source, data = ohm_req_or (return identity) begin 
	MProfile.find_self (ctx # myself)
	|> Run.map (IProfile.Deduce.self_can_view)
	|> Run.bind MProfile.data 
      end in
      
      let form_init =
	let date_fmt = MFmt.date (I18n.language i18n) in
	let str = Json_type.Build.string and opt = Json_type.Build.optional in
	FMember.Edit.Form.initialize MProfile.Data.(function
	  | `Firstname -> str (data.firstname)
	  | `Lastname  -> str (data.lastname) 
	  | `Birthdate -> opt (date_fmt.Fmt.to_json) (data.birthdate)
	  | `Email     -> opt str (data.email) 
	  | `Phone     -> opt str (data.phone)
	  | `Cellphone -> opt str (data.cellphone)
	  | `Address   -> opt str (data.address)
	  | `Zipcode   -> opt str (data.zipcode) 
	  | `City      -> opt str (data.city) 
	  | `Country   -> opt str (data.country) 
	  | `Gender    -> opt (MFmt.Gender.to_json) (data.gender) 
	  | `Pic       -> opt ((CFile.get_pic_fmt cuid).Fmt.to_json) (data.picture)
	)
      in
      
      let! self    = ohm $ ctx # self in
      let! details = ohm $ MAvatar.details self  in 
      
      let! picture = ohm $ CPicture.small MProfile.Data.(data.picture) in
      
      return $ VMyOptions.Info.page
	~name:(`text (CName.get i18n details))
	~source
	~form_url:"TODO"
	~options_url:(UrlMyOptions.home # build (ctx # instance) ^ "/share")
	~form_init
	~uploader:(CFile.pic_uploader i18n)
	~gender:(CGender.picker i18n)
	~picture
	~data
	~i18n
    end

module Share = struct

  module Form   = FShare.Profile.Form
  module Fields = FShare.Profile.Fields

  let action ~ctx = 
    O.Box.reaction "share-post" begin fun self bctx data response ->
    
      let share = ref `Basic in
      let form = Form.readpost (bctx # post)
        |> Form.mandatory `What Fields.What.fmt share (ctx#i18n,`label "")
      in
      
      if Form.not_valid form then 
	return (Action.json (Form.response form) response)
      else
	let share = match !share with 
	  | `Basic      -> Some [`basic]
	  | `Default    -> None
	  | `Everything -> Some [`basic;`birth;`email;`phone;
				 `cellphone;`address;`city;`country;`gender]
	in
	
	let! pid = ohm $ MProfile.find_self (ctx # myself) in
	let! ()  = ohm $ MProfile.Sharing.set pid share in
	
	return $ Action.javascript 
	  (Js.message (I18n.get (ctx # i18n) (`label "changes.saved"))) response

    end
	  
end 
      
let share_box ~(ctx:'any CContext.full) = 
  let i18n = ctx # i18n in
  let! post = Share.action ~ctx in
  O.Box.leaf
    begin fun bctx url ->

      let! sharing = ohm begin
	MProfile.find_self (ctx # myself)
	|> Run.map (IProfile.Deduce.self_can_view)
	|> Run.bind MProfile.Sharing.get 
      end in 

      let asso = ctx # instance # name in
      let form_init = FShare.Profile.Form.initialize begin function `What -> 
	( match sharing with 
	  | None          -> `Default
	  | Some []       -> `Basic
	  | Some [`basic] -> `Basic
	  | _             -> `Everything)
	|> FShare.Profile.Fields.What.to_json
      end in
 
      return $ VMyOptions.Share.page
	~asso
	~form_url:(bctx # reaction_url post) 
	~form_init
	~i18n
    end
 

let tabs_box ~(ctx:'any CContext.full) = 
  let i18n    = ctx # i18n in
  let tablist = [
    CTabs.fixed `Info  (`label "my_options.tab.info")  (lazy (info_box ~ctx)) ;
    CTabs.fixed `Share (`label "my_options.tab.share") (lazy (share_box ~ctx))
  ] in
  CTabs.box 
    ~list:tablist 
    ~url:(UrlR.build (ctx # instance))
    ~seg:CSegs.myOptions_tabs 
    ~default:`Info
    ~i18n

let home_box ~(ctx:'any CContext.full) = 
  let i18n    = ctx # i18n in
  let content = "c" in
  O.Box.node 
    begin fun input _ -> 
      return [content, tabs_box ~ctx],
      return (VMyOptions.home_page ~content:(input # name,content) ~i18n)
    end
