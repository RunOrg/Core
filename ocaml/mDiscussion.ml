(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MDiscussion_core
module Can  = MDiscussion_can

type 'relation t = 'relation Can.t

module Satellite = struct

  type action = 
    [ `Wall   of [ `Manage | `Read | `Write ]
    | `Folder of [ `Manage | `Read | `Write ]
    ]

  let access _ _ = assert false

end

module Signals = struct
  let on_update_call, on_update = Sig.make (Run.list_iter identity) 
end

module Get = struct
  let id _ = assert false
  let title _ = assert false
  let update _ = assert false
  let creator _ = assert false
  let iid _ = assert false
  let groups _ = assert false
  let body _ = assert false
end

let create actor ~title ~body ~groups = 
  assert false

module Set = struct
  let edit _ _ ~title ~body = assert false
end

include HEntity.Get(Can)(Core)

let delete d actor = 
  assert false
