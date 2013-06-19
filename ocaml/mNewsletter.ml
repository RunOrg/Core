(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MNewsletter_core
module Can  = MNewsletter_can
module Set  = MNewsletter_set
module Get  = MNewsletter_get

type 'relation t = 'relation Can.t

module Satellite = struct

  type action = 
    [ `Wall   of [ `Manage | `Read | `Write ]
    | `Folder of [ `Manage | `Read | `Write ]
    ]

  let access t = function
    | `Wall   `Manage
    | `Folder `Manage  -> return MAvatarStream.admins
    | `Wall   (`Read | `Write)  
    | `Folder (`Read | `Write) -> Can.view_access t 

end

module Signals = struct
  let on_bind_inboxLine_call, on_bind_inboxLine = Sig.make (Run.list_iter identity)
  let on_update = Core.on_update
  let on_send_call, on_send = Sig.make (Run.list_iter identity) 
  let () = 
    let! id, diffs = Sig.listen Core.on_version in 
    let  asids = List.concat (List.map (function 
      | `Send asids -> asids
      | `SetTitle _
      | `SetBody _
      | `Delete _ -> []) diffs) in
    on_send_call (id, asids)
end

let create actor ~title ~body = 
  O.decay begin
    let  nlid  = INewsletter.gen () in
    let! time = ohmctx (#time) in 
    let  init = Core.({
      iid   = IInstance.decay (MActor.instance actor) ;
      gids  = [] ;
      title = "" ;
      body  = `Text "" ;
      time  ;
      crea  = IAvatar.decay (MActor.avatar actor) ;
      del   = None ;
    }) in
    let diffs = [
      `SetTitle   title ;
      `SetBody    body ;
    ] in
    let! () = ohm $ Core.create nlid actor init diffs in
    let! () = ohm $ Signals.on_bind_inboxLine_call nlid in
    return nlid 
  end 

include HEntity.Get(Can)(Core)

let delete t self = 
  Set.update [`Delete (IAvatar.decay (MActor.avatar self))] t self 
