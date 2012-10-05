(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let () = define UrlMe.News.def_home begin fun owid cuid ->
  O.Box.fill (O.decay begin

    (* Acting as confirmed self to view items. *)
    let  uid = IUser.Deduce.current_is_self (ICurrentUser.Assert.is_old cuid) in
    let! avatars = ohm $ MAvatar.user_avatars uid in

    let! items = ohm (Run.list_collect begin fun (self, isin) ->

      let  access = Run.memo (CAccess.of_isin isin) in
      let  readable fid = 
	let! access = ohm_req_or (return None) access in 
	let! feed   = ohm_req_or (return None) (MFeed.try_get access fid) in
	let! feed   = ohm_req_or (return None) (MFeed.Can.read feed) in
	return (Some (MFeed.Get.id feed))
      in

      MItem.news ~self readable (IIsIn.instance isin) 

    end avatars) in 

    let items = List.sort (fun a b -> compare (b # time) (a # time)) items in 
		     
    let item item = Html.(concat [ 
      str "<li><b>" ; 
      esc (IItem.to_string (item # id)) ; 
      str "</b> &mdash; " ; 
      esc (MFmt.date_of_float (item # time)) ;
      str "</li>"
    ]) in

    let items = Html.concat (List.map item items) in

    return items
  end)
end
