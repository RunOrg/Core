(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render access item = 
  let  fidopt = match item # payload with 
    | `Image i -> Some (i # file) 
    | _        -> None
  in
  let! pic = ohm $ Run.opt_bind (fun fid -> MFile.Url.get fid `Small) fidopt in
  return $ Some (object
    method url      = "javascript:void(0)"
    method pic      = pic
    method comments = if item # ncomm = 0 then None else Some item # ncomm 
  end)
 
let items more access album start = 
  let! items, next = ohm $ MItem.list ~self:(access # self) (`album (MAlbum.Get.id album)) ~count:9 start in
  let! items = ohm $ Run.list_filter (render access) items in 
  let  more  = match next with 
    | None      -> None
    | Some time -> Some (OhmBox.reaction_endpoint more time,Json.Null)
  in
  return (items, more)

let album_rw more access album walbum = 
  O.Box.fill begin 
    let! items, more = ohm $ O.decay (items more access album None) in 
    let  iid = IInstance.Deduce.can_see_usage (MAlbum.Get.write_instance walbum) in 
    let! used, full = ohm $ O.decay (MFile.Usage.instance iid) in 
    Asset_Album_List.render (object
      method upload = Some (object 
	method prepare = Action.url UrlUpload.Client.Img.prepare (access # instance # key) 
	  (IAlbum.decay (MAlbum.Get.id album))
	method free    = full -. used 
      end)
      method items = items
      method more  = more
    end)
  end

let album_ro more access album = 
  let! items, more = ohm $ O.decay (items more access album None) in 
  O.Box.fill (Asset_Album_ListReadOnly.render (object
    method upload = None
    method items  = items
    method more   = more
  end))

let album_none () = 
  O.Box.fill (Asset_Album_ListNone.render ())

let getmore access album = begin fun time _ self res -> 
  let! items, more = ohm $ O.decay (items self access album (Some time)) in
  let! html = ohm $ Asset_Album_More.render (object
    method items = items
    method more  = more
  end) in
  return $ Action.json ["more", Html.to_json html] res
end

let box access album =
  match album with
    | None -> album_none () 
    | Some album -> let! writable = ohm (O.decay (MAlbum.Can.write album)) in
		    let! more = O.Box.react Fmt.Float.fmt (getmore access album) in 
		    match writable with 
		      | None        -> album_ro more access album
		      | Some walbum -> album_rw more access album walbum
			
