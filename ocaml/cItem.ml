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

  let comments = 
    if item # ncomm > 0 then
      Some (object
	method more = if item # ncomm > List.length (item # ccomm) then Some () else None 
	method list = Run.list_filter CComment.render_by_id (item # ccomm) 
      end)
    else None
  in

  let self = access # self in

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
    method reply    = Some ()
    method remove   = Some ()
    method hide     = None 
  end) in

  return (Some html)

 
