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

class ctx ?session adlib = object (self)
  inherit CouchDB.init_ctx
  inherit Async.ctx
  inherit [i18n] AdLib.ctx adlib
  method date = Date.of_timestamp (self # time) 
  method track_logs = (session : OhmTrackLogs.session option)
end

let ctx ?session = function
  | `FR -> new ctx ?session Asset_AdLib.fr

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

let () = 
  OhmTrackLogs.file_prefix := "/var/log/ozone/track." ^ env

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
  let existed, session, res = OhmTrackLogs.get_session req res in 
  Run.with_context (ctx ~session `FR) begin 

    let url  = Action.url (req # self) (req # server) (req # args) in
    let mode = if req # post <> None then "POST" else "GET" in
    let landing = Json.of_opt Json.of_string (req # get "land") in

    (* If first time we see session, log "First" *)
    let! () = ohm 
      (if existed then return () else OhmTrackLogs.log (Json.Array [ Json.String "F" ; landing ])) in

    (* Log the request anyway *)
    let! () = ohm $ OhmTrackLogs.log (Json.Array [ Json.String "R" ; Json.String mode ; Json.String url ]) in

    f req res

  end

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

let decay run = Run.edit_context (fun ctx -> (ctx :> ctx)) run
