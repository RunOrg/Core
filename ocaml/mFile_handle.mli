(* © 2013 RunOrg *)

type handle = { 
  id     : Ohm.Id.t ; 
  store  : IFile.Storage.t ;
  storeT : Ohm.Json.t ;
  fileT  : Ohm.Json.t ;
}

include Ohm.Fmt.FMT with type t = handle

val url : handle -> (#O.ctx,string option) Ohm.Run.t

val download : handle -> (#O.ctx,<
  filename : string ;
  local : string ;
  size : float
> option) Ohm.Run.t

val provider : handle -> #O.ctx MFile_store.provider option 

