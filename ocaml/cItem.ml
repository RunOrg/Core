(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Message = struct

  let render item message = 
    let body = Asset_Item_Message.render (object
      method body = OhmText.format ~nl2br:true ~skip2p:true ~mailto:true ~url:true (message # text)
    end) in
    (message # author, `Message, body)

end

let () = UrlClient.Item.def_comments $ CClient.action begin fun access req res -> 
 
  let  fail = return res in
  let  cuid = IIsIn.user (access # isin) in

  let  itid, proof = req # args in
  let! itid = req_or fail $ IItem.Deduce.from_read_token cuid itid proof in
  
  let! comments = ohm $ MComment.all itid in
  let! htmls = ohm $ Run.list_map (snd |- CComment.render) comments in
  let  html = Html.concat htmls in

  return $ Action.json ["all", Html.to_json html] res

end

let render access item = 

  let! now = ohmctx (#time) in

  let! author, action, body = req_or (return None) $ match item # payload with 
    | `Message  m -> Some (Message.render item m) 
    | `MiniPoll m -> None
    | `Image    i -> None
    | `Doc      d -> None
    | `Chat     c -> None
    | `ChatReq  r -> None
  in  

  let! author = ohm $ CAvatar.mini_profile author in 

  let more_comments = 
      Action.url UrlClient.Item.comments (access # instance # key) 
    ( let cuid = IIsIn.user (access # isin) in
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

  let! html = ohm $ Asset_Item_Wrap.render (object
    method author   = author
    method body     = body
    method action   = action
    method time     = (item # time,now)
    method comments = comments
    method like     = Some (CLike.render (CLike.item access (item # id)) likes (item # nlike)) 
    method remove   = Some ()
    method reply    = CComment.reply access (IItem.Deduce.read_can_reply (item # id)) 
  end) in

  return (Some html)

 
