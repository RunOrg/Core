(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Vision = MEvent_vision 
module Config = MEvent_config

module Cfg = struct

  let name = "event"

  module DataDB = struct
    let database = O.db "event"
    let host = "localhost"
    let port = 5984
  end

  module VersionDB = struct
    let database = O.db "event-v"
    let host = "localhost"
    let port = 5984
  end

  module Id = IEvent

  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetDraft   of bool 
      | `SetName    of string option
      | `SetVision  of Vision.t
      | `SetPicture of IFile.t option
      | `SetDate    of Date.t option 
      | `SetAdmins  of MAccess.t	  
      | `EditConfig of Config.Diff.t list
      | `Delete     of IAvatar.t
      ]
  end)

  module Data = struct
    module T = struct
      type json t = {
	iid    : IInstance.t ;
	tid    : ITemplate.Event.t ;
	gid    : IGroup.t ;
	name   : string option ;
	date   : Date.t option ;
	pic    : IFile.t option ;
	vision : Vision.t ;
	admins : MAccess.t ;
	draft  : bool ;
	config : Config.t ;
	del    : IAvatar.t option ;
      }
    end
    include T
    include Fmt.Extend(T)
  end 

  type ctx = O.ctx

  let couchDB ctx = (ctx : O.ctx :> CouchDB.ctx) 

  module VersionData = MUpdateInfo

  module ReflectedData = Fmt.Unit

  let do_apply t = Data.(function 
    | `SetDraft   draft  -> { t with draft }
    | `SetName    name   -> { t with name }
    | `SetVision  vision -> { t with vision }
    | `SetPicture pic    -> { t with pic }
    | `SetDate    date   -> { t with date }
    | `SetAdmins  admins -> { t with admins }
    | `EditConfig diffs  -> { t with config = Config.apply diffs t.config }
    | `Delete     aid    -> { t with del = Some (BatOption.default aid t.del) } 
  )
    
  let apply diff = 
    return (fun _ _ t -> return (do_apply t diff))

  let reflect _ _ = return () 

end

type data_t = Cfg.Data.t = {
  iid    : IInstance.t ;
  tid    : ITemplate.Event.t ;
  gid    : IGroup.t ;
  name   : string option ;
  date   : Date.t option ;
  pic    : IFile.t option ;
  vision : Vision.t ;
  admins : MAccess.t ;
  draft  : bool ;
  config : Config.t ;
  del    : IAvatar.t option ;
}

include HEntity.Core(Cfg) 

type diff_t = diff

