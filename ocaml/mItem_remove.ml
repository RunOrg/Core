(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal
 
open MItem_common
open MItem_db

let schedule_deletion = 

  let task = O.async # define "scheduled-item-deletion" IItem.fmt begin fun itid ->
    
    let  finish = return () in
    let! item   = ohm_req_or finish (Tbl.get itid) in
    let! ()     = true_or finish (item # del) in

    let! ()     = ohm begin 
      (* Can delete contents because we are deleting item *)
      match item # payload with
	| `Message  _ -> return ()
	| `Mail     _ -> return () 
	| `MiniPoll p -> MPoll.delete_now (IPoll.Assert.bot (p # poll)) 
	| `Image    i -> MOldFile.delete_now (IFile.Assert.bot (i # file))
	| `Doc      d -> MOldFile.delete_now (IFile.Assert.bot (d # file))
    end in

    Tbl.delete itid

  end in

  fun itid -> task ~delay:30.0 itid

let delete d = object
  method del      = true
  method delayed  = d # delayed
  method where    = d # where
  method payload  = d # payload
  method time     = d # time
  method clike    = d # clike 
  method nlike    = d # nlike
  method ccomm    = d # ccomm
  method ncomm    = d # ncomm
  method iid      = d # iid
end
  
let moderate itid from =

  let! item_opt = ohm $ Tbl.Raw.transaction (IItem.decay itid) begin fun itid ->
    let! item = ohm_req_or (return (None,`keep)) $ Tbl.get itid in 
    let! _ = ohm_req_or (return (None,`keep)) $ from (item # where) in
    let  item = delete item in 
    return (Some item, `put item) 
  end in

  match item_opt with None -> return () | Some item ->
    if item # del then schedule_deletion (IItem.decay itid) else return ()
  
let delete itid =    
  let! _  = ohm $ Tbl.update (IItem.decay itid) delete in
  let! () = ohm $ schedule_deletion (IItem.decay itid) in
  return ()
