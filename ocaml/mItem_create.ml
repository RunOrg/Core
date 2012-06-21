(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Signals = MItem_signals
module Types   = MItem_types

open MItem_db
open MItem_common

let create ~payload ~delayed ~where ~iid (itid:[`Created] IItem.id) = 

  let id   = IItem.decay itid     in
  let time = Unix.gettimeofday () in 

  let obj = object
    method del      = false
    method delayed  = delayed
    method where    = decay where
    method time     = time
    method clike    = []
    method nlike    = 0
    method ccomm    = []
    method ncomm    = 0
    method payload  = payload
    method iid      = IInstance.decay iid
  end in

  let! created = ohm $ MyTable.transaction id (MyTable.insert obj) in
  let! ()      = ohm $ Signals.on_post_call (Types.bot_item_of_data id created) in

  return () 
  
let image ctx album =  

  let  instance = MAlbum.Get.write_instance album in 
  let  user     = IIsIn.user (ctx # isin) in 
  let! self     = ohm $ ctx # self in
  let  itid     = IItem.Assert.created (IItem.gen ()) (* Creating it right now *) in

  (* Attempt to create image-uploader on this instance *)
  let! img = ohm_req_or (return None) $ MFile.Upload.prepare_img 
    ~ins:instance
    ~usr:(IUser.Deduce.unsafe_is_anyone user)
    ~item:itid
  in
  
  (* Prepare item contents *)
  let payload = `Image (object
    method author = IAvatar.decay self
    method file   = IFile.decay img 
  end) in

  let where = `album (IAlbum.decay (MAlbum.Get.id album)) in 

  let iid = IInstance.decay instance in 

  (* Create the item with the contents. *)
  let! () = ohm $ create ~where ~payload ~delayed:true ~iid itid in

  return $ Some (itid, img)
  
let doc ctx folder =  

  let  instance = MFolder.Get.write_instance folder in 
  let  user     = IIsIn.user (ctx # isin) in 
  let! self     = ohm $ ctx # self in
  let  itid     = IItem.Assert.created (IItem.gen ()) (* Creating it right now *) in

  (* Attempt to create file-uploader on this instance. *)
  let! doc = ohm_req_or (return None) $ MFile.Upload.prepare_doc 
    ~ins:instance
    ~usr:(IUser.Deduce.unsafe_is_anyone user)
    ~item:itid
  in

  (* Prepare item contents *)
  let where = `folder (IFolder.decay (MFolder.Get.id folder)) in

  let payload = `Doc (object 
    method author = IAvatar.decay self
    method file   = IFile.decay doc
    method title  = "" 
    method ext    = `File
    method size   = 0.
  end) in

  let iid = IInstance.decay instance in

  (* Create the item with the contents. *)
  let! () = ohm $ create ~where ~payload ~delayed:true ~iid itid in

  return $ Some (itid, doc)

let message self text iid where = 
  
  let payload = `Message (object
    method author = IAvatar.decay self 
    method text   = if String.length text > 3000 then String.sub text 0 3000 else text
  end) in

  let where = `feed where in 

  let itid = IItem.Assert.created (IItem.gen ()) in

  let! () = ohm $ create ~where ~payload ~delayed:false ~iid itid in

  return itid

let chat_request self topic iid where = 
  
  let payload = `ChatReq (object
    method author = IAvatar.decay self 
    method topic  = if String.length topic > 150 then String.sub topic 0 150 else topic
  end) in

  let where = `feed where in 

  let iid  = IInstance.decay iid in 
  let itid = IItem.Assert.created (IItem.gen ()) in

  let! () = ohm $ create ~where ~payload ~delayed:false ~iid itid in

  return itid


let poll self text poll iid where = 
  
  let payload = `MiniPoll (object
    method author = IAvatar.decay self 
    method text   = if String.length text > 3000 then String.sub text 0 3000 else text
    method poll   = IPoll.decay poll 
  end) in

  let where = `feed where in 

  let itid = IItem.Assert.created (IItem.gen ()) in

  let! () = ohm $ create ~where ~payload ~delayed:false ~iid itid in

  return itid

(* Automated creation in reaction to events ----------------------------------------------- *)

let () = 
  let! crid, feed = Sig.listen MChat.Room.Signals.on_create in 
  let  iid  = MFeed.Get.instance feed in 
  let  itid = IItem.Assert.created (IItem.gen ()) in
  
  (* Prepare item contents *)
  let payload = `Chat (object
    method room   = IChat.Room.decay crid
  end) in
  
  let where = `feed (IFeed.decay (MFeed.Get.id feed)) in
  
  (* Create the item with the contents. *)
  create ~where ~payload ~delayed:true ~iid itid
