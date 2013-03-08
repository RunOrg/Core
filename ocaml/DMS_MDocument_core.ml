(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Version = DMS_MDocument_version 

module Cfg = struct

  let name = "dms-doc"

  module Id = DMS_IDocument

  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetName    of string
      | `Share      of DMS_IRepository.t 
      | `Unshare    of DMS_IRepository.t 
      | `AddVersion of Version.t 
      ]
  end)

  module Data = struct
    module T = struct
      type json t = {
	iid     : IInstance.t ;
	name    : string ; 
	repos   : DMS_IRepository.t list ;
	version : Version.t ;
	creator : IAvatar.t ; 
	last    : float * IAvatar.t ;
      }
    end
    include T
    include Fmt.Extend(T)
  end 

  let do_apply t = Data.(function 
    | `SetName    name   -> { t with name }
    | `Share      rid    -> if List.mem rid t.repos then t else { t with repos = rid :: t.repos }
    | `Unshare    rid    -> { t with repos = BatList.remove t.repos rid }
    | `AddVersion v      -> let v' = t.version in 
			    (* Add a version only if it recent. 
			       Also, the version number needs to be set here. *)
			    if v' # time > v # time then t else  
			      { t with 
				version = Version.number (1 + v' # number) v ; 
				last = (v # time, v # author) }
  )
    
  let apply diff = 
    return (fun _ _ t -> return (do_apply t diff))

end

type data_t = Cfg.Data.t = {
  iid     : IInstance.t ;
  name    : string ; 
  repos   : DMS_IRepository.t list ;
  version : Version.t ;
  creator : IAvatar.t ; 
  last    : float * IAvatar.t ;
}

include HEntity.Core(Cfg) 

type diff_t = diff
