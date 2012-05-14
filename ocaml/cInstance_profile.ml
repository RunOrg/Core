(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInstance.Profile

let box ~(ctx:'a CContext.full) = 

  let  cuid = IIsIn.user (ctx # myself) in
  let  iid  = IInstance.decay (IIsIn.instance (ctx # myself)) in
  let! follow_reaction = CDigest.follow_reaction cuid iid  in

  let contents = "feed" in
  O.Box.node begin fun bctx _ ->
    return [contents, CBroadcast.box ~ctx],
    begin 
      let  iid     = IIsIn.instance (ctx # myself) in
      let! profile = ohm $ get iid in
      let  profile = BatOption.default (empty iid) profile in 
      
      let  no_desc = ctx # reword (`label "instance.no-desc")in
      let  tags = 
	if profile # tags = [] then None else 
	  Some (List.map String.lowercase profile # tags)
      in 

      let! follow = ohm $ MDigest.Subscription.follows (IIsIn.user (ctx # myself)) iid in

      let! followers  = ohm $ MDigest.Subscription.count_followers (IInstance.decay iid) in
      let! broadcasts = ohm $ MBroadcast.count (IInstance.decay iid) in

      let stats = VNetwork.ProfileStats.render (object
	method url        = bctx # reaction_url follow_reaction
	method follow     = follow
	method followers  = followers
	method broadcasts = broadcasts
      end) in

      return $ VInstance.Profile.Index.render (object
	method desc     = let d = I18n.translate (ctx # i18n) no_desc in
			BatOption.default d profile # desc
	method address  = let a = BatString.trim (BatOption.default "" profile # address) in
			  if a = "" then None else Some a
	method website  = let w = BatString.trim (BatOption.default "" profile # site) in
			  if w = "" then None else Some w
	method tags     = tags
	method contact  = let c = BatString.trim (BatOption.default "" profile # contact) in
			  if c = "" then None else Some c
	method facebook = let f = BatString.trim (BatOption.default "" profile # facebook) in
			  if f = "" then None else Some f
	method twitter  = let t = BatString.trim (BatOption.default "" profile # twitter) in
			  if t = "" then None else Some t
	method phone    = let p = BatString.trim (BatOption.default "" profile # phone) in
			  if p = "" then None else Some p
	method enlarge  = Some (I18n.translate (ctx # i18n) (`label "show-details"))
	method feed     = (bctx # name, contents)
	method stats    = stats
      end) (ctx # i18n) 
    end
  end
