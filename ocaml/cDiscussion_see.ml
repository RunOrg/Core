(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define ~back:(Action.url UrlClient.Inbox.home) UrlClient.Discussion.def_see begin fun access -> 
  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! did = O.Box.parse IDiscussion.seg in

  let! discn = ohm_req_or e404 $ MDiscussion.view ~actor did in
  let! admin = ohm $ MDiscussion.Can.admin discn in

  let! feed   = ohm $ O.decay (MFeed.get_for_owner actor (`Discussion did)) in
  let! feed   = ohm $ O.decay (MFeed.Can.read feed) in

  let! folder = ohm $ O.decay (MFolder.get_for_owner actor (`Discussion did)) in
  let! folder = ohm $ O.decay (MFolder.Can.read folder) in

  let! wallbox = O.Box.add (CWall.box (Some `Discussion) access feed) in
  let! filebox = O.Box.add (CFolder.box ~compact:true access folder) in
      
  O.Box.fill $ O.decay begin

    (* Mark everything as read --------------------------------------------------------------------------- *) 

    let! () = ohm $ MInboxLine.View.mark (access # actor) (`Discussion did) in

    (* Top and side details ------------------------------------------------------------------------------ *)

    let! now  = ohmctx (#time) in

    let  title = MDiscussion.Get.title discn in
    let  body  = MDiscussion.Get.body discn in

    (* Administrator URLs -------------------------------------------------------------------------------- *)

    let admin = 
      if admin <> None then 
	Some (object
	  method url = Action.url UrlClient.Discussion.admin (access # instance # key) 
	    [ IDiscussion.to_string did ]
	end)
      else 
	None
    in

    (* Render the page ----------------------------------------------------------------------------------- *)

    Asset_Discussion_Page.render (object
      method admin      = admin
      method title      = title
      method page       = MRich.OrText.to_html body
      method files      = O.Box.render filebox
      method wall       = O.Box.render wallbox
    end)
  end
end
