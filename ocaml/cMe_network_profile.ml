(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let profile_box i18n user iid = 
  let contents = "feed" in
  let! follow_reaction = CDigest.follow_reaction user iid  in
  O.Box.node begin fun bctx _ ->
    return [contents,CBroadcast.unbound_box i18n user iid], 
    begin 
      let no_profile = return identity in 
      
      let! profile = ohm_req_or no_profile $ MInstance.Profile.get iid in
      let! pic = ohm $ CPicture.large (profile # pic) in
      
      let! inst_follow = ohm begin       
	let  uid = IUser.Deduce.current_is_anyone user in
	let! is_admin = ohm $ MAvatar.is_admin uid in
	let  url = UrlMe.build 
	  O.Box.Seg.(UrlSegs.(
	    root ++ me_pages ++ me_network_tabs `Follow ++ instance_id))
	  ((((),`Network),`Follow),Some iid)
	in
	if is_admin then 
	  return $ VCore.FollowLinkButton.render url
	else
	  return (fun _ -> Ohm.View.str "&nbsp;") 
      end in
      
      let! follow = ohm $ MDigest.Subscription.follows user iid in
      
      let! followers  = ohm $ MDigest.Subscription.count_followers (IInstance.decay iid) in
      let! broadcasts = ohm $ MBroadcast.count (IInstance.decay iid) in
      
      let stats = VNetwork.ProfileStats.render (object
	method url        = bctx # reaction_url follow_reaction
	method follow     = follow
	method followers  = followers
	method broadcasts = broadcasts
      end) in
      
      return $ VInstance.UnboundProfile.Index.render (object
	method name     = profile # name
	method picture  = pic
	method stats    = stats 
	method follow   = inst_follow
	method enlarge  = Some (I18n.translate i18n (`label "show-details"))
	method desc     = let d = I18n.translate i18n (`label "instance.no-desc") in
			  BatOption.default d profile # desc
	method address  = let a = BatString.trim (BatOption.default "" profile # address) in
			  if a = "" then None else Some a
	method website  = let w = BatString.trim (BatOption.default "" profile # site) in
			  if w = "" then None else Some w
	method tags     = 
	  if profile # tags = [] then None else 
	    Some (List.map String.lowercase profile # tags)
	method contact  = let c = BatString.trim (BatOption.default "" profile # contact) in
			  if c = "" then None else Some c
	method facebook = let f = BatString.trim (BatOption.default "" profile # facebook) in
			  if f = "" then None else Some f
	method twitter  = let t = BatString.trim (BatOption.default "" profile # twitter) in
			  if t = "" then None else Some t
	method phone    = let p = BatString.trim (BatOption.default "" profile # phone) in
			  if p = "" then None else Some p
	method feed     = (bctx # name, contents)
      end) i18n 
	
    end
  end
 
let box i18n user = 
  O.Box.decide begin fun _ (prefix,iid_opt) ->
    match iid_opt with
      | None -> return $ O.Box.leaf (fun _ _ -> return identity) 
      | Some iid -> return $ profile_box i18n user iid
  end 
  |> O.Box.parse UrlSegs.instance_id
