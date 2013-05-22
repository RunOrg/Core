(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Vision = MGroup_vision 
module Config = MGroup_config

module Cfg = struct

  let name = "group"

  module Id = IGroup

  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetName    of TextOrAdlib.t option
      | `SetVision  of Vision.t
      | `SetAdmins  of IDelegation.t	  
      | `EditConfig of Config.Diff.t list
      | `Delete     of IAvatar.t
      ]
  end)

  module Data = struct
    module T = struct
      type json t = {
	iid    : IInstance.t ;
	tid    : ITemplate.Group.t ;
	gid    : IAvatarSet.t ;
	name   : TextOrAdlib.t option ;
	vision : Vision.t ;
	admins : IDelegation.t ;
	config : Config.t ;
	del    : IAvatar.t option ;
      }
    end
    include T
    include Fmt.Extend(T)
  end 

  let do_apply t = Data.(function 
    | `SetName    name   -> { t with name }
    | `SetVision  vision -> { t with vision }
    | `SetAdmins  admins -> { t with admins }
    | `EditConfig diffs  -> { t with config = Config.apply diffs t.config }
    | `Delete     aid    -> { t with del = Some (BatOption.default aid t.del) } 
  )
    
  let apply diff = 
    return (fun _ _ t -> return (do_apply t diff))

end

type data_t = Cfg.Data.t = {
  iid    : IInstance.t ;
  tid    : ITemplate.Group.t ;
  gid    : IAvatarSet.t ;
  name   : TextOrAdlib.t option ;
  vision : Vision.t ;
  admins : IDelegation.t ;
  config : Config.t ;
  del    : IAvatar.t option ;
}

include HEntity.Core(Cfg) 

type diff_t = diff

