(* © 2012 RunOrg *)

open Ohm
open BatPervasives

let env = match O.environment with 
  | `Dev  -> "dev"
  | `Prod -> "prod"

(* A few preliminary definitions ----------------------------------------------------- *)

module type CONFIG = sig
  val db : string
end

module Configure = functor(Config:CONFIG) -> struct
  let host     = "localhost"
  let port     = 5984
  let database = env^"-"^Config.db
end

module Register = functor(N:CONFIG) -> ( struct
  module C = Configure(N)
  include CouchDB.Database(C)
end : CouchDB.DATABASE )

(* All available databases ------------------------------------------------------------ *)

module AlbumDB    = Register (struct let db = "album" end)
module AvatarDB   = Register (struct let db = "avatar" end)
module CmsDB      = Register (struct let db = "cms" end)
module ConfigDB   = Register (struct let db = "config" end)
module ErrorDB    = Register (struct let db = "error" end)
module FileDB     = Register (struct let db = "file" end)
module GridDB     = Register (struct let db = "grid" end)
module InstanceDB = Register (struct let db = "instance" end)
module MainDB     = Register (struct let db = "main" end)
module MessageDB  = Register (struct let db = "message" end)
module NewsDB     = Register (struct let db = "new" end)
module NotifyDB   = Register (struct let db = "notify" end)
module PollDB     = Register (struct let db = "poll" end)
module SondageDB  = Register (struct let db = "sondage" end)
module TalkDB     = Register (struct let db = "talk" end)
module TaskDB     = Register (struct let db = "task" end)
module TemplateDB = Register (struct let db = "template" end)
module TokenDB    = Register (struct let db = "token" end)
module UpdateDB   = Register (struct let db = "update" end)

module ProfileAuditDB     = Register (struct let db = "audit-profile" end)

(* Secondary definitions -------------------------------------------------------------- *)

module I18n      = I18n.Loader(TemplateDB)
module Template  = Template.Loader(ConfigDB)
module Reset     = Reset.Make(ConfigDB)
module Task      = Task.Make(TaskDB)

module Facebook = struct

  module Config = Fmt.Make(struct
    type json t = <
      app_id     : string ;
      api_key    : string ;
      api_secret : string
    > 
  end)

  module MyTable = CouchDB.Table(ConfigDB)(Id)(Config)

  let config = 
    let get = MyTable.get (Id.of_string "facebook") |> Run.map begin function 
      | Some data -> data
      | None -> Util.log "No Facebook App configuration found!" ; assert false
    end in
    get |> Run.eval (new CouchDB.init_ctx)

end

module Paypal = struct

  module MyTable = CouchDB.Table(ConfigDB)(Id)(OhmCouchPaypal.Config)

  let config, testing = 
    let get = MyTable.get (Id.of_string "paypal") |> Run.map begin function
      | Some data -> (data, false)
      | None -> 
	Util.log "Warning : using default PAYPAL configuration" ;
	(object
	  method api_username = "vnicol_1314178600_biz_api1.runorg.com"
	  method api_password = "1314178636"
	  method signature    = "ANs5H9nYYZ9EvdO2N1RJp9jVpzgsARuLmeS9KtKOQJoJjJRY9vhKg0qO"
	 end, true)
    end in
    get |> Run.eval (new CouchDB.init_ctx)

end
