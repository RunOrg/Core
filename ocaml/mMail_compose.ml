(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core    = MMail_core
module Plugins = MMail_plugins
module Send    = MMail_send

module UnsentView = CouchDB.DocView(struct
  module Key = Fmt.Float
  module Value = Fmt.Unit
  module Doc = Core.Data
  module Design = Core.Design
  let name = "unsent"
  let map = "if (!doc.dead && doc.sent === null && doc.read === null) emit(doc.time);"
end)

(* Returns [false] if it KNOWS that there are no more unsent emails
   left in the queue. [true] if there might still be more. *)
let one f = 

  let! now = ohmctx (#time) in	

  let rec retry n = 
    if n <= 0 then return true else 

      let! list = ohm (UnsentView.doc_query ~limit:1 ()) in
      match list with [] -> return false | item :: _ -> 
	let  mid = IMail.of_id (item # id) in
	
	let! locked = ohm (Core.Tbl.transact mid Core.Data.(function 
	  | None -> return (false, `keep) 
	  | Some t -> if t.sent <> None then return (false,`keep) else
	      return (true, `put { t with sent = Some now }))) in
	
	(* Lock to avoid having two bots multi-send an email... *)    
	if not locked then retry (n - 1) else 
	  
	  let  rotten = (let! () = ohm (Core.rot mid) in retry (n - 1)) in  
	  let  t      = item # doc in 
	  let! full   = ohm_req_or rotten (O.decay (Plugins.parse mid t)) in
	  let! ()     = ohm (f full) in
	  return true 
  in

  (* Discard up to 5 lock collisions or rotten emails before
     giving up, to avoid taking up too much time. *)
  retry 5

let delay = 10.0 (* seconds *)

let () = O.async # periodic 1 begin 
  let! result = ohm $ one begin fun full -> 
    let! _ = ohm $ Send.send (full # uid) begin fun self user send ->
      let! subject, text, html = ohm (full # mail self user) in
      let  owid = user # white in
      send ~owid ~from:None ~subject ~text ~html
    end in 
    return () 
  end in
  return (if result then None else Some delay)
end 
