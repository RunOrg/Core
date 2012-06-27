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

let render item = 

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

  let! html = ohm $ Asset_Item_Wrap.render (object
    method author   = author
    method body     = body
    method action   = action
    method time     = (item # time,now)
    method comments = None
    method like     = Some (CLike.render false (item # nlike)) 
    method reply    = Some ()
    method remove   = Some ()
    method hide     = None 
  end) in

  return (Some html)

 
