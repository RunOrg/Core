(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let render ~step ~hint number ctx = 
  let key = VStart.key_of_step step in 
  return (VStart.TopBar.render (object
    method number = number
    method text   = `label ("start."^key^".text")
    method more   = UrlR.build (ctx # instance) 
      O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.home_pages) 
      (((),`Home),`Start)
    method action = `label ("start."^key^".action")
    method hint   = hint ctx key
    method step   = step
  end) (ctx # i18n))


let hint ~sel ~home ctx key = 
  let url = UrlR.build (ctx # instance) 
    O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.home_pages) 
    (((),`Home),home)
  in 
  VStart.hint (ctx # i18n) 
    ~selector:sel ~gravity:`ne ~url ~hint:(`label ("start."^key^".hint"))
  
module Hint = struct

  let invite_members ctx = hint ~home:`Admins      ~sel:".green-button:first"           ctx
  let invite_ag      ctx = hint ~home:`Groups      ~sel:"a.entity:first .-name"         ctx
  let write_post     ctx = hint ~home:`Wall        ~sel:"#wall-post--text"              ctx
  let add_picture    ctx = hint ~home:`Asso        ~sel:".picUp .o"                     ctx
  let create_event   ctx = hint ~home:`Events      ~sel:".green-button:first"           ctx
  let another_event  ctx = hint ~home:`Events      ~sel:".green-button:first"           ctx 
  let invite_network ctx = hint ~home:`Network     ~sel:".green-button:first"           ctx 
  let broadcast      ctx = hint ~home:`Profile     ~sel:"#broadcast-body"               ctx 
  let buy            ctx = hint ~home:`Client      ~sel:".grey-links a:first"           ctx 

end 

let invite_members nth ctx = render ~step:`InviteMembers ~hint:Hint.invite_members nth ctx
let invite_ag      nth ctx = render ~step:`AGInvite      ~hint:Hint.invite_ag      nth ctx
let write_post     nth ctx = render ~step:`WritePost     ~hint:Hint.write_post     nth ctx
let add_picture    nth ctx = render ~step:`AddPicture    ~hint:Hint.add_picture    nth ctx
let invite_network nth ctx = render ~step:`InviteNetwork ~hint:Hint.invite_network nth ctx
let create_event   nth ctx = render ~step:`CreateEvent   ~hint:Hint.create_event   nth ctx
let create_ag      nth ctx = render ~step:`CreateAG      ~hint:Hint.create_event   nth ctx
let buy            nth ctx = render ~step:`Buy           ~hint:Hint.buy            nth ctx
let another_event  nth ctx = render ~step:`AnotherEvent  ~hint:Hint.another_event  nth ctx
let broadcast      nth ctx = render ~step:`Broadcast     ~hint:Hint.broadcast      nth ctx

let get_next_step nth ctx = function
  | `InviteMembers -> invite_members nth ctx
  | `AGInvite      -> invite_ag      nth ctx 
  | `WritePost     -> write_post     nth ctx 
  | `AddPicture    -> add_picture    nth ctx
  | `CreateEvent   -> create_event   nth ctx
  | `CreateAG      -> create_ag      nth ctx
  | `AnotherEvent  -> another_event  nth ctx 
  | `Buy           -> buy            nth ctx
  | `InviteNetwork -> invite_network nth ctx
  | `Broadcast     -> broadcast      nth ctx

let get_hint ctx step = 
  let key = VStart.key_of_step step in 
  match step with 
    | `AGInvite      -> Hint.invite_ag      ctx key
    | `InviteMembers -> Hint.invite_members ctx key
    | `WritePost     -> Hint.write_post     ctx key
    | `AddPicture    -> Hint.add_picture    ctx key
    | `CreateEvent   -> Hint.create_event   ctx key
    | `CreateAG      -> Hint.create_event   ctx key
    | `AnotherEvent  -> Hint.another_event  ctx key
    | `Buy           -> Hint.buy            ctx key
    | `InviteNetwork -> Hint.invite_network ctx key  
    | `Broadcast     -> Hint.broadcast      ctx key 
