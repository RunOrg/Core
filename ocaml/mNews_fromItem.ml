(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MNews_common

let () =
  let news_from_item item = 
    let payload  = `item (IItem.decay item # id) in
    let avatar   = MItem.author (item # payload) in 
    let instance = item # iid in 
    let time     = item # time in 

    let! entity, feed = ohm begin match item # where with 
      | `album   _ 
      | `folder  _ -> return (None, None)
      | `feed feed -> let! feed = ohm_req_or (return (None,None)) $
			MFeed.bot_get (IFeed.Assert.bot feed) in
		      match MFeed.Get.owner feed with 
			| `of_message  _ -> return (None, None)
			| `of_entity   e -> return (Some e, Some feed)
			| `of_instance _ -> return (None, Some feed)
    end in

    let access = BatOption.default [] 
      (BatOption.map (fun feed -> [`viewFeed (IFeed.decay (MFeed.Get.id feed))]) feed)
    in

    create ~instance ~avatar ~entity ~payload ~time ~access

  in

  Sig.listen MItem.Signals.on_post news_from_item
