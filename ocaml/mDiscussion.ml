(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MDiscussion_core
module Can  = MDiscussion_can
module Set  = MDiscussion_set
module Get  = MDiscussion_get

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
end

let create actor ~title ~body ~groups ~avatars = 
  O.decay begin
    let  did  = IDiscussion.gen () in
    let! time = ohmctx (#time) in 
    let  init = Core.({
      iid   = IInstance.decay (MActor.instance actor) ;
      gids  = [] ;
      aids  = [] ; 
      title = "" ;
      body  = `Text "" ;
      time  ;
      crea  = IAvatar.decay (MActor.avatar actor) ;
      del   = None ;
    }) in
    let diffs = [
      `SetTitle   title ;
      `SetBody    body ;
      `AddGroups  groups ;
      `AddAvatars avatars ;
    ] in
    let! () = ohm $ Core.create did actor init diffs in
    let! () = ohm $ Signals.on_bind_inboxLine_call did in
    return did 
  end 

include HEntity.Get(Can)(Core)

let delete t self = 
  Set.update [`Delete (IAvatar.decay (MActor.avatar self))] t self 

