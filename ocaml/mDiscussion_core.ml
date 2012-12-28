(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Cfg = struct

  let name = "discussion"

  module DataDB = struct
    let database = O.db "discussion"
    let host = "localhost"
    let port = 5984
  end

  module VersionDB = struct
    let database = O.db "discussion-v"
    let host = "localhost"
    let port = 5984
  end

  module Id = IDiscussion

  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetTitle  of string
      | `SetBody   of MRich.OrText.t
      | `AddGroups of IGroup.t list 
      | `Delete    of IAvatar.t
      ]
  end) 

  module Data = struct
    module T = struct
      type json t = {
	iid   : IInstance.t ;
	gids  : IGroup.t list ; 
	title : string ; 
	body  : MRich.OrText.t ;
	time  : float ;
	crea  : IAvatar.t ;
	del   : IAvatar.t option ;
      }
    end
    include T
    include Fmt.Extend(T)
  end

  type ctx = O.ctx

  let couchDB ctx = (ctx : O.ctx :> CouchDB.ctx) 

  module VersionData = MUpdateInfo
  module ReflectedData = Fmt.Unit

  let do_apply t time = Data.(function
    | `SetTitle  title -> { t with title ; time }
    | `SetBody   body  -> { t with body ; time }
    | `AddGroups gids  -> { t with gids = BatList.sort_unique compare (gids @ t.gids) }
    | `Delete    aid   -> { t with del = Some (BatOption.default aid t.del) }
  )

  let apply diff = 
    return (fun _ time t -> return (do_apply t time diff))

  let reflect _ _ = return () 

end

module Store = OhmCouchVersioned.Make(Cfg)

module Design = struct
  module Database = Store.DataDB
  let name = "discussion"
end

include Cfg.Data

