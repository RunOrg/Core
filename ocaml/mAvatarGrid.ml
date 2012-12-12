(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Config  = MAvatarGrid_config
module Column  = MAvatarGridColumn
module Eval    = MAvatarGridEval

module MyGrid  = OhmCouchTabular.Make(Config)

let _ = 
  let refresh uid iid =  
    let! aid = ohm $ MAvatar.become_contact iid uid in
    MyGrid.update aid (`Profiles iid)
  in
  Sig.listen MProfile.Signals.on_update (fun (_,uid,iid,_) -> refresh uid iid) 

let _ = 
  let refresh_avatar (aid,iid) = 
    MyGrid.update aid (`Avatars iid) 
  in
  Sig.listen MAvatar.Signals.on_update     refresh_avatar 
    
let _ = 
  let refresh_avatar (aid,iid) = 
    MyGrid.update_all aid 
  in
  Sig.listen MAvatar.Signals.on_obliterate refresh_avatar

let _ = 
  let refresh_membership (_,m) = 
    MMembership.(MyGrid.update m.who (`Group m.where)) 
  in
  Sig.listen MMembership.Signals.after_update refresh_membership 

let list_id (id : [`List] IAvatarGrid.id) = 
  MyGrid.ListId.of_id (IAvatarGrid.to_id $ IAvatarGrid.decay id)

let _ = 
  let create_list (lid,gid,iid,cols) = 

    let cols = MAvatarGridColumn.({
      eval  = `Profile (iid,`Full) ;
      label = `text "" ;
      view  = `Full 
    }) :: cols in 
    
    let  lid   = MyGrid.ListId.of_id $ IAvatarGrid.to_id lid in 
    MyGrid.set_list lid 
      ~columns:cols
      ~source:(`Group gid)
      ~filter:(Some (`Group (gid, `InList)))
  in
  Sig.listen MGroup.Signals.on_create_list create_list

