(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let core = List.fold_left begin fun map wid ->
  let domain = ConfigWhite.domain wid in
  let www    = "www." ^ domain in
  let server : unit Action.server = object
    method protocol  = `HTTPS
    method domain _  = domain 
    method port   _  = 443
    method cookie_domain = None
    method matches _ domain' _ = if domain = domain' || domain = www then Some () else None
  end in 
  BatPMap.add wid server map 
end BatPMap.empty ConfigWhite.all

let core wid = 
  try BatPMap.find wid core with Not_found -> 
    Util.log "Missing core white server %S" (IWhite.to_string wid) ;
    assert false
