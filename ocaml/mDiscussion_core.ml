(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Cfg = struct

  let name = "discussion"

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

  let do_apply t time = Data.(function
    | `SetTitle  title -> { t with title ; time }
    | `SetBody   body  -> { t with body ; time }
    | `AddGroups gids  -> { t with gids = BatList.sort_unique compare (gids @ t.gids) }
    | `Delete    aid   -> { t with del = Some (BatOption.default aid t.del) }
  )

  let apply diff = 
    return (fun _ time t -> return (do_apply t time diff))

end

type diff_t = Cfg.Diff.t 
type data_t = Cfg.Data.t = {
  iid   : IInstance.t ;
  gids  : IGroup.t list ; 
  title : string ; 
  body  : MRich.OrText.t ;
  time  : float ;
  crea  : IAvatar.t ;
  del   : IAvatar.t option ;
}

include HEntity.Core(Cfg)

