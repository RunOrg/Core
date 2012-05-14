(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* All available databases ------------------------------------------------------------ *)

module MainDB     = CouchDB.Convenience.Database(struct let db = O.db "main" end)
module TalkDB     = CouchDB.Convenience.Database(struct let db = O.db "talk" end)
module TemplateDB = CouchDB.Convenience.Database(struct let db = O.db "template" end)

(* Secondary definitions -------------------------------------------------------------- *)

module Paypal = struct

  module MyTable = CouchDB.Table(O.ConfigDB)(Id)(OhmCouchPaypal.Config)

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
