(* © 2013 RunOrg *)

type info = <
  handle   : MFile_handle.t ;
  filename : string ; 
  size     : float ;  
  local    : string
>

type form = string -> < post : (string * string) list ; key : string ; url : string >

module type POSTUPLOADER = sig
  include Ohm.Fmt.FMT
  val id : IFile.PostUploader.t
  val author : t -> (#O.ctx,[`Avatar of IAvatar.t | `User of IUser.t] option) Ohm.Run.t
  val process : t -> info -> (#O.ctx,unit) Ohm.Run.t
end

module Uploader : functor(P:POSTUPLOADER) -> sig

  type t = P.t

  val prepare : 
       ?maxsize:float
    -> MFile_store.store
    -> t 
    -> (#O.ctx, (MFile_uploadToken.t * form) option) Ohm.Run.t 

end

val confirm : MFile_uploadToken.t -> (#O.ctx,unit) Ohm.Run.t

