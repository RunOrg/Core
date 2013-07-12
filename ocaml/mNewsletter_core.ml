(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Cfg = struct

  let name = "newsletter"

  module Id = INewsletter

  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetTitle   of string
      | `SetBody    of MRich.OrText.t
      | `Send       of IAvatarSet.t list 
      | `Delete     of IAvatar.t
      ]
  end) 

  module Data = struct
    module T = struct
      type json t = {
	iid   : IInstance.t ;
	gids  : (IAvatarSet.t * float) list ; 
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
    | `SetTitle   title -> { t with title ; time }
    | `SetBody    body  -> { t with body ; time }
    | `Delete     aid   -> { t with del = Some (BatOption.default aid t.del) }
    | `Send       gids  -> let gids = List.map (fun gid -> gid,time) gids in 
			   let gids = List.filter 
			     (fun (gid,_) -> not (List.exists (fun (gid',_) -> gid = gid') t.gids)) gids in 
			   { t with gids = gids @ t.gids }
  )

  let apply diff = 
    return (fun _ time t -> return (do_apply t time diff))

end

type diff_t = Cfg.Diff.t 
type data_t = Cfg.Data.t = {
  iid   : IInstance.t ;
  gids  : (IAvatarSet.t * float) list ; 
  title : string ; 
  body  : MRich.OrText.t ;
  time  : float ;
  crea  : IAvatar.t ;
  del   : IAvatar.t option ;
}

include HEntity.Core(Cfg)

