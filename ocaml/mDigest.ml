(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
      last : float ;
    } 
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "digest-last" end)(IUser)(Data) 

let send_call, send = Sig.make (Run.list_iter identity) 

let start_sending uid = 
  let! _ = ohm (Tbl.ensure uid (lazy Data.({ last = 0.0 }))) in
  return () 

module Backdoor = struct

  let migrate_confirmed = Async.Convenience.foreach O.async "digest-migrate-confirmed"
    IUser.fmt (MUser.all_ids ~count:10) 
    (fun uid -> 
      let! confirmed = ohm (MUser.confirmed uid) in
      if not confirmed then return () else start_sending uid)
   
  let migrate_confirmed () = 
    migrate_confirmed () 

end 
