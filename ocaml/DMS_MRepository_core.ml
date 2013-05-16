(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Vision = DMS_MRepository_vision
module Upload = DMS_MRepository_upload
module Remove = DMS_MRepository_remove
module Detail = DMS_MRepository_detail

module Cfg = struct

  let name = "dms-repo"

  module Id = DMS_IRepository

  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetName    of string
      | `SetVision  of Vision.t
      | `SetUpload  of Upload.t 
      | `SetRemove  of Remove.t 
      | `SetDetail  of Detail.t 
      | `SetAdmins  of IDelegation.t
      | `Delete     of IAvatar.t
      ]
  end)

  module Data = struct
    module T = struct
      type json t = {
	iid    : IInstance.t ;
	name   : string ;
	vision : Vision.t ;
	upload : Upload.t ;
       ?remove : Remove.t = `Free ;
       ?detail : Detail.t = `Public ; 
	admins : IDelegation.t ;
	del    : IAvatar.t option ;
      }
    end
    include T
    include Fmt.Extend(T)
  end 

  let do_apply t = Data.(function 
    | `SetName    name   -> { t with name }
    | `SetVision  vision -> { t with vision }
    | `SetUpload  upload -> { t with upload }
    | `SetRemove  remove -> { t with remove }
    | `SetDetail  detail -> { t with detail }
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
  upload : Upload.t ; 
  remove : Remove.t ;
  detail : Detail.t ;
  admins : IDelegation.t ;
  del    : IAvatar.t option ;
}

include HEntity.Core(Cfg) 

type diff_t = diff
