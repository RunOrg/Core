(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common
open MInboxLine_extract

module Push = MInboxLine_push
module ByFilter = MInboxLine_byFilter
module View = MInboxLine_view

(* Refreshing an inbox line (pushes that line to all avatars that can read it) *)
  
let line = O.async # define "inbox-line-refresh" IInboxLine.fmt 
  begin fun ilid -> 
    let! push = ohm_req_or (return ()) $ Tbl.transact ilid begin function
      | None -> return (None, `keep) 
      | Some current -> let! wall   = ohm $ get_wall_info   current.Line.owner current.Line.wall in 
			let! album  = ohm $ get_album_info  current.Line.owner current.Line.album in
			let! folder = ohm $ get_folder_info current.Line.owner current.Line.folder in 
			let! core   = ohm $ get_core_info   current.Line.owner in 
			let! filter = ohm $ get_filter      current.Line.owner in 
			
			let last_album = BatOption.bind album (fun a -> a.Info.Album.last) in
			let filter = if last_album <> None then `HasPics :: filter else filter in 

			let last_folder = BatOption.bind folder (fun f -> f.Info.Folder.last) in
			let filter = if last_folder <> None then `HasFiles :: filter else filter in 

			let  times  = [ 
			  BatOption.bind wall (fun w -> w.Info.Wall.last) ;
			  last_album ; 
			  last_folder ; 
			  core ; 
			] in
			
			let last  = List.fold_left max current.Line.last times in 
			let push  = current.Line.push + 1 in
			let show  = true in
			let fresh = Line.({ current with 
			  wall ; album ; folder ; last ; push ; show ; filter }) in
			return (Some push,`put fresh)
    end in
    Push.schedule ilid push 
  end

let line ilid = 
  O.decay (line ilid)

(* Refreshing a group (pushes all lines from that group to a specific avatar) *)

module GroupRefreshFmt = Fmt.Make(struct
  type json t = (IAvatar.t * IGroup.t * IInboxLine.t option)
end)

let group, def_group = O.async # declare "inbox-group-refresh" GroupRefreshFmt.fmt 
let () = def_group begin fun (aid, gid, start) ->
  let! lines, next = ohm (ByFilter.all ?start ~count:5 (`Group gid)) in
  let! () = ohm (Run.list_iter (fun (ilid,line) -> View.update ilid aid line) lines) in
  if next = None then return () else group (aid, gid, next)
end

let group aid gid = 
  O.decay (group (aid,gid,None)) 
