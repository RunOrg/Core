(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Notify = CItem_notify

module Message = struct

  let render item message = 
    let body = Asset_Item_Message.render (object
      method body = `Text message # text
    end) in
    (message # author, `Message, body)

end

module Mail = struct

  let render item message = 
    let body = Asset_Item_Mail.render (object
      method body    = `Text message # body
      method subject = message # subject
    end) in
    (message # author, `Mail, body)

end

module Poll = struct

  module AnswerFmt = Fmt.Make(struct type json t = int list end)

  let () = UrlClient.MiniPoll.def_vote $ CClient.action begin fun access req res -> 
    
    let  fail = return res in
    let  cuid = MActor.user (access # actor) in
    
    let  pid, proof = req # args in
    let! pid = req_or fail $ IPoll.Deduce.from_answer_token cuid pid proof in
  
    let! json = req_or fail $ Action.Convenience.get_json req in
    let! answers = req_or fail $ AnswerFmt.of_json_safe json in
    
    let! () = ohm $ MPoll.Answer.set (access # self) pid answers in

    return res

  end

  let render access item poll = 
    let body = 

      let pid  = IPoll.Deduce.read_can_answer (poll # poll) in
      let vote = 
	Action.url UrlClient.MiniPoll.vote (access # instance # key) 
	  ( let cuid = MActor.user (access # actor) in
	    let proof = IPoll.Deduce.make_answer_token cuid pid in
	    (IPoll.decay pid, proof) ) 
      in

      let display answers count total questions = Asset_Item_Poll.render (object
	method body = `Text poll # text
	method questions = questions
	method count = count
	method total = total
	method answers = answers
	method url = vote
      end) in

      let! p       = ohm_req_or (display None [] 0 []) $ MPoll.get (poll # poll) in
      let  details = MPoll.Get.details p in
      let! questions = ohm $ Run.list_map begin fun (i,q) -> 
	let! label = ohm $ TextOrAdlib.to_string q in
	return (object
	  method n = i
	  method label = label 
	  method multi = details # multiple
	end)
      end (BatList.mapi (fun i x -> i,x) (details # questions))	in

      let stats = MPoll.Get.stats p in
      let count = List.map snd (stats # answers) in
      
      let  self = access # self in
      let! answered = ohm $ MPoll.Answer.answered self (poll # poll) in
      let! answers  = ohm $ MPoll.Answer.get self (poll # poll) in
      
      let  answers = if answered then Some answers else None in 

      display answers count (stats # total) questions

    in
    (poll # author, `MiniPoll, body)

end

let render ?moderate access item = 

  let! now = ohmctx (#time) in

  let! author, action, body = req_or (return None) $ match item # payload with 
    | `Message  m -> Some (Message.render item m) 
    | `MiniPoll m -> Some (Poll.render access item m)
    | `Mail     m -> Some (Mail.render item m) 
    | `Image    i -> None
    | `Doc      d -> None
    | `Chat     c -> None
    | `ChatReq  r -> None
  in  

  let! author = ohm $ CAvatar.mini_profile author in 

  let more_comments = 
    Action.url UrlClient.Item.comments (access # instance # key) 
      ( let cuid = MActor.user (access # actor) in
	let proof = IItem.Deduce.(make_read_token cuid (item # id)) in
	(IItem.decay (item # id), proof) )
  in

  let comments = object
    method more = 
      if item # ncomm > List.length (item # ccomm) then 
	Some (object
	  method url = more_comments
	end) 
      else None 
    method list = Run.list_filter CComment.render_by_id (List.rev (item # ccomm)) 
  end in

  let  self = access # self in

  let! likes = ohm begin
    if List.mem (IAvatar.decay self) (item # clike) then return true else
      if item # nlike = List.length (item # clike) then return false else
	MLike.likes self (`item (item # id))
  end in

  let remove = match item # own with 
    | Some own -> Some (object
      method url = Action.url UrlClient.Item.remove (access # instance # key) 
	( let cuid = MActor.user (access # actor) in
	  let proof = IItem.Deduce.(make_remove_token cuid (own_can_remove own)) in
	  (IItem.decay (item # id), proof) ) 
    end)
    | None -> match moderate with 
	| Some f -> Some (object method url = f (IItem.decay (item #id)) end)
	| None   -> None
  in

  let! html = ohm $ Asset_Item_Wrap.render (object
    method author   = author
    method body     = body
    method action   = action
    method time     = (item # time,now)
    method comments = comments
    method like     = Some (CLike.render (CLike.item access (item # id)) likes (item # nlike)) 
    method remove   = remove
    method reply    = CComment.reply access (IItem.Deduce.read_can_reply (item # id)) 
  end) in

  return (Some html)

module PostForm = Fmt.Make(struct
  type json t = <
    text    : string ;
   ?subject : string option ; 
   ?poll    : string list = [] ;
   ?multi   : bool = false
  > 
end)

let post access feed json res = 
  
  let! post = req_or (return res) $ PostForm.of_json_safe json in 
  let  iid  = IInstance.decay access # iid 
  and  fid  = MFeed.Get.id feed
  and  actor = access # actor  in 

  let! afid  = ohm begin 
    let! admin = ohm_req_or (return None) $ MFeed.Can.admin feed in 
    return $ Some (MFeed.Get.id admin) 
  end in

  let! itid = ohm begin 
    if post # poll = [] then 
      match afid, post # subject with 
	| Some afid, Some subject ->
	  MItem.Create.mail actor ~subject (post # text) iid afid
	| _ -> 
	  MItem.Create.message actor (post # text) iid fid 
    else 
      let! poll = ohm $ MPoll.create (object
	method multiple = post # multi
	method questions = List.map (fun t -> `text t)
	  (List.filter (function "" -> false | _ -> true) 
	     (List.map BatString.strip (post # poll)))
      end) in
      MItem.Create.poll actor (post # text) poll iid fid
  end in

  let! item = ohm_req_or (return res) $ MItem.try_get actor itid in
  let! html = ohm_req_or (return res) $ render access item in 
  
  return $ Action.json ["post", Html.to_json html] res
  
let () = UrlClient.Item.def_comments $ CClient.action begin fun access req res -> 
 
  let  fail = return res in
  let  cuid = MActor.user (access # actor) in

  let  itid, proof = req # args in
  let! itid = req_or fail $ IItem.Deduce.from_read_token cuid itid proof in
  
  let! comments = ohm $ MComment.all itid in
  let! htmls = ohm $ Run.list_map (snd |- CComment.render) comments in
  let  html = Html.concat htmls in

  return $ Action.json ["all", Html.to_json html] res

end

let () = UrlClient.Item.def_moderate $ CClient.action begin fun access req res -> 
 
  let  fail = return res in
  let! json = req_or fail (Action.Convenience.get_json req) in 

  let actor = access # actor in 

  let  itid = req # args in
  
  let admin = function
    | `feed fid -> let! feed = ohm_req_or (return None) $ MFeed.try_get actor fid in 
		   let! feed = ohm_req_or (return None) $ MFeed.Can.admin feed in 
		   return (Some (`feed (MFeed.Get.id feed))) 
    | `album aid -> let! album = ohm_req_or (return None) $ MAlbum.try_get actor aid in 
		    let! album = ohm_req_or (return None) $ MAlbum.Can.admin album in 
		    return (Some (`album (MAlbum.Get.id album))) 
    | `folder fid -> let! folder = ohm_req_or (return None) $ MFolder.try_get actor fid in 
		     let! folder = ohm_req_or (return None) $ MFolder.Can.admin folder in 
		     return (Some (`folder (MFolder.Get.id folder))) 
  in

  let!  () = ohm $ MItem.Remove.moderate itid admin in

  return res

end

let () = UrlClient.Item.def_remove $ CClient.action begin fun access req res -> 
 
  let  fail = return res in
  let  cuid = MActor.user (access # actor) in

  let  itid, proof = req # args in
  let! itid = req_or fail $ IItem.Deduce.from_remove_token cuid itid proof in
  
  let!  () = ohm $ MItem.Remove.delete itid in

  return res

end

