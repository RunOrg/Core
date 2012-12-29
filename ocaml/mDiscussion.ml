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

  let access _ _ = assert false

end

module Signals = struct
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
    return did 
  end 

include HEntity.Get(Can)(Core)

let delete t self = 
  Set.update [`Delete (IAvatar.decay (MActor.avatar self))] t self 
