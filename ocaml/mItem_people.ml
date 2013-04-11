(* © 2013 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

open MItem_common
open MItem_db

let interested itid item = 
  let  itid = IItem.Assert.bot itid in
  let! likers     = ohm $ MLike.interested itid in 
  let! commenters = ohm $ MComment.interested itid in
  let  list = likers @ commenters in
  let  list = match MItem_data.author item with None -> list | Some aid -> aid :: list in 
  return $ BatList.sort_unique compare list 

