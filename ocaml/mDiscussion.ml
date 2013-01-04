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
    | `Folder `Manage  -> `Union (Can.admin_access t)
    | `Wall   (`Read | `Write)  
    | `Folder (`Read | `Write) -> `Union (Can.view_access t)

end

module Signals = struct
  let on_bind_inboxLine_call, on_bind_inboxLine = Sig.make (Run.list_iter identity)
  let on_update = Core.on_update
end

let create actor ~title ~body ~groups = 
  O.decay begin
    let  did  = IDiscussion.gen () in
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
      `SetTitle  title ;
      `SetBody   body ;
      `AddGroups groups ;
    ] in
    let! () = ohm $ Core.create did actor init diffs in
    let! () = ohm $ Signals.on_bind_inboxLine_call did in
    return did 
  end 

include HEntity.Get(Can)(Core)

let delete t self = 
  Set.update [`Delete (IAvatar.decay (MActor.avatar self))] t self 

(* {{InboxLine}} *)

let migrate_all = Async.Convenience.foreach O.async "create-discussion-inboxLines"
  IDiscussion.fmt (Core.Tbl.all_ids ~count:100) Signals.on_bind_inboxLine_call 

let () = O.put (migrate_all ()) 
