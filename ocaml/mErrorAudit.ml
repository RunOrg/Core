(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "error" end)
module Design = struct
  module Database = MyDB
  let name = "audit"
end

module Data = Fmt.Make(struct
  module IUser = IUser
  type json t = <
    time : string ;
    server : string ;
    url : string ;
    user : IUser.t option ;
    exn : string ;
    backtrace : string
  >
end)

module MyTable = CouchDB.Table(MyDB)(Id)(Data)

type t = Data.t

(* THIS MODULE ENABLES EXCEPTION BACKTRACE RECORDING *)
let () = Printexc.record_backtrace true
(* ===== *)

let print = function
  | Failure reason -> Printf.sprintf "Failure %S" reason
  | Http_client.Http_error (n,s) -> Printf.sprintf "HTTP %d : %s" n s 
  | exn -> Printexc.to_string exn

let make ~server ~url ~user ~exn = 
  let backtrace = Printexc.get_backtrace () in
  ( object
    method time      = Unix.gettimeofday () |> Util.string_of_time
    method server    = server
    method url       = url
    method user      = user
    method exn       = print exn
    method backtrace = backtrace
    end )

module Signals = struct
  let on_create_call, on_create = Sig.make (Run.list_iter identity)
end

let notify error = 
  Signals.on_create_call error

let on_frontend ~server ~url ~user ~exn = 
  let error = make ~server ~url ~user ~exn in
  let id = Id.gen () in
  MyTable.transaction id (MyTable.insert error) |> Run.bind notify

