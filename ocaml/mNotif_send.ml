(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core    = MNotif_core
module Plugins = MNotif_plugins

module UnsentView = CouchDB.DocView(struct
  module Key = Fmt.Float
  module Value = Fmt.Unit
  module Doc = Core.Data
  module Design = Core.Design
  let name = "unsent"
  let map = "if (!doc.dead && doc.sent === null && doc.read === null) emit(doc.time);"
end)

(* Returns [false] if it KNOWS that there are no more unsent notifications
   left in the queue. [true] if there might still be more. *)
let one f = 

  let rec retry n = 
    if n <= 0 then return true else 

      let! list = ohm (UnsentView.doc_query ~limit:1 ()) in
      match list with [] -> return false | item :: _ -> 
	let  nid = INotif.of_id (item # id) in
	let! now = ohmctx (#time) in
	
	let! locked = ohm (Core.Tbl.transact nid Core.Data.(function 
	  | None -> return (false, `keep) 
	  | Some t -> if t.sent <> None then return (false,`keep) else
	      return (true, `put { t with sent = Some now }))) in
	
	(* Lock to avoid having two bots multi-send a notification... *)    
	if not locked then retry (n - 1) else 
	  
	  let  rotten = (let! () = ohm (Core.rot nid) in retry (n - 1)) in  
	  let  t      = item # doc in 
	  let! full   = ohm_req_or rotten (O.decay (Plugins.parse nid t)) in
	  let! ()     = ohm (f full) in
	  return true 
  in

  (* Discard up to 5 lock collisions or rotten notifications before
     giving up, to avoid taking up too much time. *)
  retry 5

