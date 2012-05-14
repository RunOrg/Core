(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Showing the actual poll (as an attachment in a wall) ------------------------------------ *)

let show_stats ~(ctx:'any CContext.full) pid =
  let i18n = ctx # i18n in
  MPoll.get pid |> Run.map begin function
    | None -> identity
    | Some poll ->

      let stats = MPoll.Get.stats poll in
      
      let user    = IIsIn.user (ctx # myself) in
      let apid    = IPoll.Deduce.read_can_answer pid in
      let swap    = (UrlWall.swap_form_poll ()) # build (ctx # instance) user apid in
      let details = (UrlWall.poll_details ()) # build (ctx # instance) user apid in

      VPoll.view 
	~swap
	~details
	~stats
	~i18n	
  end

let show_form ~(ctx:'any CContext.full) pid =
  let i18n = ctx # i18n in 
  MPoll.get pid |> Run.map begin function
    | None      -> identity
    | Some poll -> 

      let details = MPoll.Get.details poll in
      
      let config   = object
	method answers = BatList.mapi (fun i x -> (i,x)) (details # questions) 
      end in

      let user     = IIsIn.user (ctx # myself) in
      let apid     = IPoll.Deduce.read_can_answer pid in
      let form_url = (UrlWall.post_poll ()) # build (ctx # instance) user apid in
      let swap_url = (UrlWall.swap_view_poll ()) # build (ctx # instance) user apid in
      
      if details # multiple then 
	let dynamic = BatList.mapi (fun i _ -> `Answer i) (details # questions) in
	let init = FPoll.Multiple.Form.dynamic dynamic in
	VPoll.form_multiple
	  ~form_url
	  ~swap_url
	  ~form_config:config
	  ~form_init:init
	  ~form_dynamic:dynamic
	  ~i18n
      else 
	let init = FPoll.Single.Form.empty in
	VPoll.form_single
	  ~form_url
	  ~swap_url
	  ~form_config:config
	  ~form_init:init
	  ~i18n
  end  

(* Posting a poll answer ------------------------------------------------------------------- *)

let () = CClient.User.register CClient.is_contact (UrlWall.post_poll ())
  begin fun ctx request response ->

    let i18n = ctx # i18n in 
    let fail = Action.javascript (Js.message (I18n.get i18n (`label "changes.error"))) response in
    
    let! id      = req_or (return fail) $ request # args 0 in
    let  poll_id = IPoll.of_string id in 
    let! poll_p  = req_or (return fail) (request # args 1) in
    
    let !pid     = 
      req_or (return fail) $
	(IPoll.Deduce.from_answer_token (IIsIn.user (ctx # myself)) poll_id poll_p)
    in

    MPoll.get pid |> Run.bind begin function None -> return fail | Some poll ->
      let details = MPoll.Get.details poll in 

      let answers = match details # multiple with 
	| true -> 
	  
	  let form = FPoll.Multiple.Form.readpost (request # post) in
	  
	  details # questions 
	    
	  |> BatList.mapi begin fun i _ -> 
	    let extract = ref None in 
  	    let _ = FPoll.Multiple.Form.optional (`Answer i) Fmt.Bool.fmt extract form in
	    if !extract = Some true then Some i else None
	  end
	      
	  |> BatList.filter_map identity

	| false -> 
	  
	  let form = FPoll.Single.Form.readpost (request # post) in
	  let extract = ref None in
	  let _ = FPoll.Single.Form.optional `Question Fmt.Int.fmt extract form in
	  
	  ( match !extract with None -> [] | Some i -> [i] ) 
      in

      let! self = ohm $ ctx # self in
        
      let! () = ohm $ MPoll.Answer.set self pid answers in
      
      let! view = ohm $ show_stats ~ctx (IPoll.Deduce.answer_can_read pid) in
      
      return $ Action.javascript (Js.replaceWith ".-attach" view) response
	    
    end
  end

(* Displaying an item ----------------------------------------------------------------------- *)

let register ctrl what = 
  CClient.User.register CClient.is_contact ctrl 
    begin fun ctx request response ->
      
      let i18n = ctx # i18n in
      let fail = Action.javascript (Js.message (I18n.get i18n (`label "changes.error"))) response in

      let! id      = req_or (return fail) $ request # args 0 in
      let  poll_id = IPoll.of_string id in 
      let! poll_p  = req_or (return fail) (request # args 1) in
      
      let !pid     = 
	req_or (return fail) $
	  (IPoll.Deduce.from_answer_token (IIsIn.user (ctx # myself)) poll_id poll_p)
      in

      what ~ctx (IPoll.Deduce.answer_can_read pid) |> Run.map begin fun view ->      
	Action.javascript (Js.replaceWith ".-attach" view) response
      end
    
    end

let _ = 
  register (UrlWall.swap_view_poll ()) (show_stats) ;
  register (UrlWall.swap_form_poll ()) (show_form)

(* Displaying poll vote details ------------------------------------------------------------ *)

let () = CClient.User.register CClient.is_contact (UrlWall.poll_details ())
  begin fun ctx request response ->

    let i18n = ctx # i18n in 
    let fail = Action.javascript (Js.message (I18n.get i18n (`label "view.error"))) response in
    
    
    let! id      = req_or (return fail) $ request # args 0 in
    let  poll_id = IPoll.of_string id in 
    let! poll_p  = req_or (return fail) (request # args 1) in
    
    let !pid     = 
      req_or (return fail) $
	(IPoll.Deduce.from_answer_token (IIsIn.user (ctx # myself)) poll_id poll_p)
    in

    let! answer = req_or (return fail) begin 
      match request # args 2 with
	| None -> None
	| Some a -> try Some (int_of_string a) with _ -> None
    end in 

    let rpid = IPoll.Deduce.answer_can_read pid in 

    MPoll.Answer.get_all ~count:10 rpid answer |> Run.bind begin fun avatars ->      
      CAvatar.extract i18n ctx avatars |> Run.map begin fun avatar_details ->	
	let body = VPoll.view_details ~list:avatar_details ~i18n in
	Action.json (Js.Html.return body) response	
      end
    end

  end
