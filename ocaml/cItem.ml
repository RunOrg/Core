(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render item = 

  let! now = ohmctx (#time) in

  let! author, action = req_or (return None) $ match item # payload with 
    | `Message  m -> Some (m # author, `Message)
    | `MiniPoll m -> None
    | `Image    i -> None
    | `Doc      d -> None
    | `Chat     c -> None
    | `ChatReq  r -> None
  in  

  let! author = ohm $ CAvatar.mini_profile author in 

  let! html = ohm $ Asset_Item_Wrap.render (object
    method author   = author
    method body     = return (Html.str "")
    method action   = action
    method time     = (item # time,now)
    method comments = ""
    method like     = None
    method reply    = None
    method remove   = None
    method hide     = None
  end) in

  return (Some html)

 
