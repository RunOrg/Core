(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Remove = MItem_remove

open MItem_db

let () = 
  let like (who,what) =
    
    let update count item = object
      method del      = item # del
      method delayed  = item # delayed 
      method where    = item # where
      method payload  = item # payload
      method time     = item # time
      method clike    = BatList.unique ((IAvatar.decay who) ::
					   (BatList.take 14 (item # clike)))
      method nlike    = count
      method ccomm    = item # ccomm
      method ncomm    = item # ncomm
      method iid      = item # iid
    end in
    
    match what with 
      | `item what -> let! count = ohm $ MLike.count (`item what) in 
		      Tbl.update (IItem.decay what) (update count) 
      | _          -> return ()
  in
  
  Sig.listen MLike.Signals.on_like like
    
let () = 
  let unlike (who,what) = 
    
    let update count item = object
      method del      = item # del
      method delayed  = item # delayed
      method time     = item # time
      method clike    = BatList.remove_all (item # clike) (IAvatar.decay who) 
      method nlike    = count
      method ccomm    = item # ccomm
      method ncomm    = item # ncomm
      method where    = item # where
      method iid      = item # iid
      method payload  = item # payload
    end in
    
    match what with 
      | `item what -> let! count = ohm $ MLike.count (`item what) in
		      Tbl.update (IItem.decay what) (update count)
      | _          -> return ()
  in
  
  Sig.listen MLike.Signals.on_unlike unlike
    
let () = 
  let comment (id,comment) = 
    let update item = object
      method del      = item # del
      method time     = item # time
      method clike    = item # clike
      method nlike    = item # nlike
      method ccomm    = (IComment.decay id) :: (BatList.take 1 (item # ccomm))
      method ncomm    = 1 + item # ncomm
      method payload  = item # payload
      method iid      = item # iid
      method delayed  = item # delayed
      method where    = item # where
    end in
    Tbl.update (comment # on) update
  in
  
  Sig.listen MComment.Signals.on_create comment

let () = 
  let uncomment (cid,iid) = 
    let update item = object
      method del      = item # del
      method time     = item # time
      method clike    = item # clike
      method nlike    = item # nlike
      method ccomm    = BatList.remove_all (item # ccomm) cid 
      method ncomm    = item # ncomm - 1
      method payload  = item # payload
      method delayed  = item # delayed
      method where    = item # where
      method iid      = item # iid
    end in
    Tbl.update iid update
  in
  
  Sig.listen MComment.Signals.on_delete uncomment

let () = 
  let upload id = 
    
    let update item = object
      method del     = item # del
      method delayed = false
      method time    = item # time
      method clike   = item # clike
      method nlike   = item # nlike
      method ccomm   = item # ccomm
      method ncomm   = item # ncomm
      method payload = item # payload
      method where   = item # where
      method iid     = item # iid
    end in 
    Tbl.update id update
  in

  Sig.listen MFile.Upload.Signals.on_item_img_upload upload

let () = 
  let upload (id,name,ext,size,fid) = 

    let! id = req_or (return ()) id in

    let doc doc = object
      method author = doc # author
      method file   = fid
      method title  = name
      method ext    = ext
      method size   = size 	
    end in 

    let update item = object
      method del     = item # del
      method time    = item # time
      method clike   = item # clike
      method nlike   = item # nlike
      method ccomm   = item # ccomm
      method ncomm   = item # ncomm
      method delayed = false
      method where   = item # where
      method iid     = item # iid 
      method payload = match item # payload with 
	| `Doc d -> `Doc (doc d)
	| other  -> other (* This should not happen *)
    end in 

    Tbl.update id update
  in

  Sig.listen MFile.Upload.Signals.on_item_doc_upload upload

(* Obliterate item *)

let () = 
  (* Act as the owner to obliterate their stuff. *)
  let obliterate itid = Remove.delete (IItem.Assert.remove itid) in 
  let on_obliterate_avatar (aid,_) = 
    let! list = ohm $ ByAvatarView.doc aid in 
    let! _    = ohm $ Run.list_map (#id %> IItem.of_id %> obliterate) list in
    return ()
  in
  Sig.listen MAvatar.Signals.on_obliterate on_obliterate_avatar

