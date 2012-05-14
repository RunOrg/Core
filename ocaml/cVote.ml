(* © 2012 RunOrg *)
  
open Ohm
open BatPervasives
open Ohm.Universal

module Publish  = CVote_publish
module Vote     = CVote_vote
module Close    = CVote_close
module Read     = CVote_read
module Edit     = CVote_edit 
module Download = CVote_download

let list ~ctx ~entity ~entity_managed_opt = 
  let! publish_opt = Publish.reaction ~ctx ~entity:entity_managed_opt in
  let! do_vote     = Vote.reaction    ~ctx in
  let! do_close    = Close.reaction   ~ctx in
  let! do_edit     = Edit.reaction    ~ctx in
  let! get_short   = Download.short   ~ctx ~entity in
  let! get_long    = Download.long    ~ctx ~entity in
  let! read        = Read.reaction    ~ctx ~do_edit in
  O.Box.leaf begin fun bctx _ -> 

    let publish_actions = match publish_opt with 
      | None         -> (fun i c -> c)
      | Some publish -> let url = bctx # reaction_url publish in 
			VCore.ActionBox.render (object
			  method title   = None
			  method actions = [
			    `Button (object
			      method label = `label "votes.create"
			      method js    = Js.runFromServer url 
			      method img   = VIcon.add
			    end) 
			  ]
			end)
    in
    
    let download_actions = object
      method title   = Some (`label "votes.download")
      method actions = [
	`Link (object
	  method label = `label "votes.download.short"
	  method url   = bctx # reaction_url get_short
	  method img   = VIcon.report_go
	end) ;
	`Link (object
	  method label = `label "votes.download.full"
	  method url   = bctx # reaction_url get_long
	  method img   = VIcon.book_go
	end)
      ]
    end in 
    
    let! votes = ohm $ MVote.by_owner ctx (`entity entity) in
    let! view_votes = ohm $ Run.list_filter MVote.Can.read votes in
    let! now = ohmctx (#time) in

    let render vote = 
      let config = MVote.Config.get vote and question = MVote.Question.get vote in 

      let  aid     = MVote.Get.creator vote in 
      let! details = ohm $ MAvatar.details aid in
      let  creator = CName.get (ctx # i18n) details in
      let  profile = UrlProfile.page ctx aid in 

      let  created = MVote.Get.created vote in 

      let! answered, answers = ohm begin 
	let none = return (false, []) in
	let! self = req_or none (ctx # self_if_exists) in
	let! vote = ohm_req_or none (MVote.Can.vote vote) in
	let! answers = ohm_req_or none (MVote.Mine.get vote self) in
	return (true, answers) 
      end in 

      let! id = ohm begin 
	match config # opened_on with 
	  | Some time when time > now -> return None 
	  | _ -> let! vote = ohm_req_or (return None) (MVote.Can.vote vote) in
		 return $ Some (MVote.Get.id vote)
      end in 

      let! manage = ohm begin 
	let! vote = ohm_req_or (return None) $ MVote.Can.admin vote in

	let close = JsBase.post (bctx # reaction_url do_close) 
	  (IVote.to_json (IVote.decay (MVote.Get.id vote))) in

	let edit = JsBase.post (bctx # reaction_url do_edit) 
	  (IVote.to_json (IVote.decay (MVote.Get.id vote))) in

	return $ Some (object
	  method close = close
	  method edit  = edit
	end)	  
      end in 

      let opens_on = 
	match config # opened_on with
	    Some time when time > now -> Some time | _ -> None
      in

      let closes_on = 
	if opens_on = None then config # closed_on else None 
      in
	  
      let what   = 
	match config # closed_on with 
	  | Some time when time < now -> let id = Id.gen () in
					 `Closed (object
					   method id   = id
					   method url  = bctx # reaction_url read
					   method vote = MVote.Get.id vote
					 end)
	  | _ -> `Open (object
	    method id        = id	  
	    method opens_on  = opens_on
	    method closes_on = closes_on
	    method manage    = manage
	    method profile   = profile
	    method creator   = creator
	    method created   = created
	    method anonymous = MVote.Get.anonymous vote 
	    method multi     = question # multiple
	    method answered  = answered
	    method answers   = BatList.mapi 
	      (fun i a -> List.mem i answers, i, a) question # answers
	  end)
      in

      return (object
	method question = I18n.translate (ctx # i18n) (question # question)
	method what     = what
      end)
    in
    
    let! list = ohm $ Run.list_map render view_votes in
	
    return $ VVote.Page.render (object
      method actions = fun i c -> c 
	|> publish_actions i
	|> VCore.ActionBox.render download_actions i
      method list    = list
      method url     = bctx # reaction_url do_vote
    end) (ctx # i18n) 

  end

let box ~ctx ~entity =
  O.Box.decide begin fun _ _ -> 
    let! entity_managed_opt = ohm $ MEntity.Can.admin entity in 
    return $ list ~ctx ~entity ~entity_managed_opt
  end
