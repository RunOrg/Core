(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Server = O_server

(* Environment and basic configuration ---------------------------------------------------------------------- *)

let environment = `Prod

let role = Util.role () 

let env = match environment with 
  | `Prod    -> "prod"
  | `Dev     -> "dev"

let () = 
  Configure.set `Log begin match role with 
    | `Put
    | `Reset -> "-"
    | `Bot
    | `Web   -> "/var/log/ozone/" ^ env ^ ".log"
  end

(* Basic databases ------------------------------------------------------------------------------------------ *)

let db name = Printf.sprintf "%s-%s" env name

module ConfigDB = CouchDB.Convenience.Database(struct let db = db "config" end)
module Reset    = Reset.Make(ConfigDB)
module Proof    = OhmCouchProof.Make(ConfigDB)

(* Context management --------------------------------------------------------------------------------------- *)

type i18n = Asset_AdLib.key

class ctx adlib = object
  inherit CouchDB.init_ctx
  inherit Async.ctx
  inherit [i18n] AdLib.ctx adlib
end

let ctx = function
  | `FR -> new ctx Asset_AdLib.fr

let put action = 
  if role = `Put then 
    ignore (Ohm.Run.eval (ctx `FR) action) 

type 'a run = (ctx,'a) Run.t

module AsyncDB = CouchDB.Convenience.Config(struct let db = db "async" end)
module Async = Ohm.Async.Make(AsyncDB)

let async : ctx Async.manager = new Async.manager

let run_async () = 
  async # run (fun () -> ctx `FR) 

let page = Ohm.Html.print_page

(* Action management ---------------------------------------------------------------------------------------- *)

let domain = match environment with 
  | `Prod    -> "runorg.com"
  | `Dev     -> 
    match Run.eval (ctx `FR) (ConfigDB.get (Id.of_string "local")) with 
      | None -> "dev.runorg.com"
      | Some _ -> "runorg.local"

let server = Server.server domain
let core   = Server.core domain 
let client = Server.client domain
let secure = Server.secure domain

let action f req res = 
  Run.with_context (ctx `FR) (f req res)

let register s u a body = 
  Action.register s u a (action body)

let declare s u a = 
  let endpoint, define = Action.declare s u a in
  endpoint, action |- define

(* Box management ------------------------------------------------------------------------------------------- *)

module BoxCtx = struct
  class t adlib (box:OhmBox.ctx) = object
    inherit ctx adlib
    val box = box
    method get_box = box
    method set_box box = {< box = box >}
  end
  let get t = t # get_box
  let set box t = t # set_box box
  let make box = 
    let! ctx = ohmctx identity in
    return (new t (ctx # adlib) box) 
end

module Box = OhmBox.Make(BoxCtx)

type 'a boxrun = (BoxCtx.t,'a) Run.t 

let decay run = (run : 'a run :> 'a boxrun) 
