(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Fields = FWall.Post.Fields
module Form   = FWall.Post.Form
  
let create ~(ctx:'any CContext.full) ~config ~feed ~feed_hid = 
  O.Box.reaction "new-post" begin fun self input _ response ->
    
    let i18n = ctx # i18n in
    let text = ref None in 
    let form = Form.readpost (input # post) |> Form.optional `Text Fmt.String.fmt text in
    
    let earlyout = Action.json (Form.response form) response in
    
    let text = match !text with None -> "" | Some text -> BatString.trim text in
    
    if text = "" then return earlyout else      
      
      let user = IIsIn.user (ctx # myself) in 
      let instance = ctx # myself |> IIsIn.instance |> IInstance.decay in 
      
      let! avatar = ohm $ ctx # self in
      
      let! iid    = ohm $ MItem.Create.message avatar text instance (MFeed.Get.id feed) in
      
      let  riid = IItem.Deduce.created_can_reply  iid in
      let  liid = IItem.Deduce.created_can_like   iid in
      let rmiid = IItem.Deduce.created_can_remove iid in
      
      let! details = ohm $ MAvatar.details avatar in
      let  name    = CName.get (ctx # i18n) details in 
      let! pic     = ohm $ ctx # picture_small (details # picture) in
           
      let id = Id.gen () in
      
      let data = new VWall.item 
	~id
	~url:(UrlProfile.page ctx avatar)
	~pic
	~name
	~text
	~liked:false
	~likes:0
	~like:((UrlWall.like_item ()) # build (ctx # instance) user liid)
	~reply:((UrlWall.reply ()) # build (ctx # instance) id user riid) 
	~replies:[]
	~remove:(Some ((UrlWall.remove ()) # build (ctx # instance) user rmiid))
	~react:(config # react)
	~date:(Unix.gettimeofday ())
	~role:None
	~kind:`none
	~attach:identity
	~more:None
      in
      
      return $ Action.javascript (Js.wallPost feed_hid (VWall.Item.render data i18n)) response
	
  end
