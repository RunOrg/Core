(* © 2012 RunOrg *)
  
open Ohm
open BatPervasives
open Ohm.Universal

module Edit = CVote_edit

let reaction ~ctx ~do_edit = 
  O.Box.reaction "read" begin fun _ bctx _ response -> 

    let send html = return $ O.Action.json (Js.Html.return html) response in 
    let fail = send identity in 

    let! vid  = req_or fail (bctx # post "id") in
    let! vote = ohm_req_or fail $ MVote.try_get ctx (IVote.of_string vid) in
    let! vote = ohm_req_or fail $ MVote.Can.read vote in 
    let! stat = ohm $ MVote.Stats.get_short vote in 

    let! manage = ohm begin 

      let! vote = ohm_req_or (return None) $ MVote.Can.admin vote in
    
      let edit = JsBase.post (bctx # reaction_url do_edit) 
	(IVote.to_json (IVote.decay (MVote.Get.id vote))) in
      
      return $ Some edit 

    end in 

    let answers = List.map (fun (label, count) -> (object
      method label   = label
      method count   = count
      method percent = float_of_int count /. float_of_int (stat # count) 
    end)) (stat # votes) in

    let! now = ohmctx (#time) in

    let config = MVote.Config.get vote in 

    let  aid     = MVote.Get.creator vote in 
    let! details = ohm $ MAvatar.details aid in
    let  creator = CName.get (ctx # i18n) details in
    let  profile = UrlProfile.page ctx aid in 
    
    let html = VVote.VoteStats.render (object
      method answers = answers
      method voters  = stat # count
      method created = MVote.Get.created vote
      method creator = creator
      method profile = profile
      method closed  = BatOption.default now (config # closed_on) 
      method edit    = manage
    end) (ctx # i18n) in
 
    send html

  end 

