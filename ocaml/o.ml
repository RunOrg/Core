(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let environment = `Retheme 

let env = match environment with 
  | `Prod    -> "prod"
  | `Dev     -> "dev"
  | `Retheme -> "dev"

let db name = Printf.sprintf "%s-%s" env name

let () = 
  Configure.set `Log begin match Ohm.Util.role with 
    | `Put
    | `Reset -> "-"
    | `Bot
    | `Web   -> "/var/log/ozone/" ^ env ^ ".log"
  end

let domain = match environment with 
  | `Prod    -> "runorg.com"
  | `Dev     -> "dev.runorg.com"
  | `Retheme -> "runorg.local"

let core   = Action.Convenience.single_domain_server domain
let client = Action.Convenience.sub_domain_server ("." ^ domain)
let secure = Action.Convenience.single_domain_server ~secure:true domain

module ConfigDB = CouchDB.Convenience.Database(struct let db = db "config" end)
module Reset    = Reset.Make(ConfigDB)
module Proof    = OhmCouchProof.Make(ConfigDB)

class ctx adlib = object
  inherit CouchDB.init_ctx
  inherit Async.ctx
  inherit [Asset_AdLib.key] AdLib.ctx adlib
end

let ctx = function
  | `FR -> new ctx Asset_AdLib.fr

type 'a run = (ctx,'a) Run.t

module AsyncDB = CouchDB.Convenience.Config(struct let db = db "async" end)
module Async = Ohm.Async.Make(AsyncDB)

let async : ctx Async.manager = new Async.manager

let run_async () = 
  async # run (fun () -> ctx `FR) 

let action f req res = 
  Run.with_context (ctx `FR) (f req res)

let register s u a body = 
  Action.register s u a (action body)

let declare s u a = 
  let endpoint, define = Action.declare s u a in
  endpoint, action |- define
