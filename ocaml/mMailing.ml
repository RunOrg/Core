(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
      mailing : string ;
      email   : string ;
      name    : string ;
      url     : string ;
      clicks  : float list ;
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "mailing" end)(Id)(Data)

let create ~mailing ~email ~name ~url = 
  Tbl.create Data.({ mailing ; email ; name ; url ; clicks = [] })

let click id = 
  let! now = ohmctx (#time) in
  Tbl.transact id Data.(function 
    | None -> return (None, `keep) 
    | Some d -> return (Some (d.url, d.mailing), `put { d with clicks = now :: d.clicks }))
