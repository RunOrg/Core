(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

module Store = MFile_store

module I = Fmt.Make(struct
  type json t = (Id.t * IFile.Storage.t * Json.t * Json.t)
end)

type handle = { 
  id     : Id.t ; 
  store  : IFile.Storage.t ;
  storeT : Json.t ;
  fileT  : Json.t ;
}

module T = struct

  type t = handle

  let t_of_json json = 
    let id, store, storeT, fileT = I.of_json json in 
    { id ; store ; storeT ; fileT }

  let json_of_t t = 
    I.to_json (t.id,t.store,t.storeT,t.fileT)

end

include T
include Fmt.Extend(T)

let provider t = 
  Store.provider (t.store, t.storeT)

let url t = 
  let! provider = req_or (return None) (provider t) in
  provider # url t.fileT

let download t = 
  let! provider = req_or (return None) (provider t) in
  provider # download t.fileT

