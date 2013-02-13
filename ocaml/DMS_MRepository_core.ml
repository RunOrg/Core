(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Vision = DMS_MRepository_vision

module Cfg = struct

  let name = "dms-repo"

  module Id = DMS_IRepository

  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetName    of string
      | `SetVision  of Vision.t
      | `SetAdmins  of MAccess.t	  
      | `Delete     of IAvatar.t
      ]
  end)

  module Data = struct
    module T = struct
      type json t = {
	iid    : IInstance.t ;
	name   : string ;
	vision : Vision.t ;
	admins : MAccess.t ;
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
    | `Delete     aid    -> { t with del = Some (BatOption.default aid t.del) } 
  )
    
  let apply diff = 
    return (fun _ _ t -> return (do_apply t diff))

end

type data_t = Cfg.Data.t = {
  iid    : IInstance.t ;
  name   : string ;
  vision : Vision.t ;
  admins : MAccess.t ;
  del    : IAvatar.t option ;
}

include HEntity.Core(Cfg) 

type diff_t = diff
