(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let cookie_email = "R_EMAIL"
let cookie_last  = "R_LAST"

(* Subscribing to an instance ------------------------------------------------------------- *)

let () = CCore.register UrlNetwork.subscribe begin fun i18n request response -> 

  (* Extract the IID *)
  let  fail = return $ O.Action.redirect (UrlNetwork.explore # build []) response in
  let! last = req_or fail $ request # args 0 in
  let   iid = IInstance.of_string last in

  (* Extract the sent e-mail *)
  let    url = UrlNetwork.profile # build iid in
  let   fail = return $ O.Action.redirect url response in 
  let! email = req_or fail (request # post "email") in
  let  email = BatString.strip email in 
  let! ()    = true_or fail (email <> "") in

  (* Detect whether the user exists... *)
  let! uid, confirmed = ohm $ MUser.listener_create email in

  if confirmed then
    return $ O.Action.redirect (UrlLogin.index # build) response
  else
    let  cuid = IUser.Assert.is_unsafe uid in 
    let! ()   = ohm $ MDigest.Subscription.subscribe cuid iid in
    return (response
	     |> O.Action.with_cookie ~name:cookie_email ~value:email ~life:3600
	     |> O.Action.with_cookie ~name:cookie_last  ~value:last  ~life:3600
	     |> O.Action.redirect url)
end

(* Exploring based on tags ---------------------------------------------------------------- *)

let () = CCore.register UrlNetwork.explore begin fun i18n request response -> 

  let render_list tag_opt = 

    let count = 20 in
    
    let! list, _ = ohm begin match tag_opt with 
      | Some tag -> MInstance.Profile.by_tag ~count tag 
      | None     -> MInstance.Profile.all ~count () 
    end in
    
    let render_tag tag = object
      method url = UrlNetwork.explore # build [String.lowercase tag]
      method tag = String.lowercase tag
    end in
    
    let render_profile data = 
      let! pic = ohm $ CPicture.small data # pic in 
      return (object
	method picture = pic
	method url     = UrlNetwork.profile # build (data # id) 
	method name    = data # name
	method desc    = VText.head 300 (BatOption.default "" data # desc)
	method tags    = List.map render_tag data # tags
      end)
    in
    
    let! profiles = ohm $ Run.list_map render_profile list in
    
    return profiles
  in
  
  let! tag_stats = ohm $ MInstance.Profile.tag_stats () in
  let render_tag (tag,count) = object
    method tag   = String.lowercase tag
    method count = count
    method url   = UrlNetwork.explore # build [String.lowercase tag] 
  end in

  let! profiles  = ohm $ render_list (request # args 0) in 
      
  let body = 
    return $ VNetwork.Public.Search.render (object
      method home = UrlNetwork.explore # build []
      method list = profiles
      method tags = List.map render_tag (List.filter (fun (tag,count) -> count > 1) tag_stats) 
    end) i18n
  in

  CCore.render 
    ~title:(return (I18n.get i18n (`label "network.title")))
    ~body
    response
    
end

(* A single profile ----------------------------------------------------------------------- *)

let () = CCore.register UrlNetwork.profile begin fun i18n request response -> 

  (* TODO *)
  let empty = return response in

  let! iid = req_or empty (request # args 0) in
  let  iid = IInstance.of_string iid in

  let  bid = BatOption.map IBroadcast.of_string (request # args 0) in

  let! profile = ohm_req_or empty $ MInstance.Profile.get iid in 
  let! pic     = ohm $ CPicture.large (profile # pic) in

  let  what = match bid with None -> `List | Some bid -> `Broadcast bid in 
  
  (* Public profile stats *)

  let! followers  = ohm $ MDigest.Subscription.count_followers iid in
  let! broadcasts = ohm $ MBroadcast.count iid in

  let stats = VNetwork.PublicProfileStats.render (object
    method followers  = followers
    method broadcasts = broadcasts
  end) in

  (* The feed *)

  let! feed = ohm $ CBroadcast.render_broadcast_list ~iid ~i18n what in

  (* The data to be rendered *) 

  let subscribed = 
    Some iid = BatOption.map IInstance.of_string (request # cookie cookie_last)
  in 

  let data = object
    method name       = profile # name
    method picture    = pic
    method stats      = stats
    method desc       = let d = I18n.translate i18n (`label "instance.no-desc") in
		        BatOption.default d profile # desc
    method website    = let w = BatString.trim (BatOption.default "" profile # site) in
		        if w = "" then None else Some w
    method facebook   = let f = BatString.trim (BatOption.default "" profile # facebook) in
		        if f = "" then None else Some f
    method twitter    = let t = BatString.trim (BatOption.default "" profile # twitter) in
		        if t = "" then None else Some t
    method feed       = feed
    method subscribe  = UrlNetwork.subscribe # build iid 
    method email      = request # cookie cookie_email
    method subscribed = subscribed
  end in 

  CCore.render 
    ~title:(return (View.esc profile # name))
    ~body:(return $ VInstance.PublicProfile.Index.render data i18n)
    response

end
