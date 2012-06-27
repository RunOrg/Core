(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal
 
open MItem_common
open MItem_db

let schedule_deletion = 

  let task = O.async # define "scheduled-item-deletion" IItem.fmt begin fun itid ->
    
    let  finish = return () in
    let! item   = ohm_req_or finish (MyTable.get itid) in
    let! ()     = true_or finish (item # del) in

    let! ()     = ohm begin 
      (* Can delete contents because we are deleting item *)
      match item # payload with
	| `Message  _ -> return ()
	| `ChatReq  _ -> return ()
	| `MiniPoll p -> MPoll.delete_now (IPoll.Assert.bot (p # poll)) 
	| `Image    i -> MFile.delete_now (IFile.Assert.bot (i # file))
	| `Doc      d -> MFile.delete_now (IFile.Assert.bot (d # file))
	| `Chat     c -> MChat.delete_now (IChat.Room.Assert.bot (c # room))
    end in

    let! _ = ohm $ MyTable.transaction itid MyTable.remove in
    
    finish

  end in

  fun itid -> task ~delay:30.0 itid

let moderate itid from =

  let delete d = object
    method del      = d # del || (d # where = decay from)
    method delayed  = d # delayed
    method where    = d # where
    method payload  = d # payload
    method time     = d # time
    method clike    = d # clike 
    method nlike    = d # nlike
    method ccomm    = d # ccomm
    method ncomm    = d # ncomm
    method iid      = d # iid
  end in

  let! item_opt = ohm $ MyTable.transaction
    (IItem.decay itid) (MyTable.update delete) 
  in

  match item_opt with None -> return () | Some item ->
    if item # del then schedule_deletion (IItem.decay itid) else return ()
  
let delete itid =
  
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
  end in
    
  let! _  = ohm $ MyTable.transaction (IItem.decay itid) (MyTable.update delete) in
  let! () = ohm $ schedule_deletion (IItem.decay itid) in
  return ()
