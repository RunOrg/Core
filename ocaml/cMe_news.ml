(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let render_item access itid = 
  let! iid = ohm_req_or (return None) $ MItem.iid itid in 
  let! access = ohm_req_or (return None) $ access iid in 
  let! item = ohm_req_or (return None) $ MItem.try_get access itid in 
  return $ Some Html.(concat [ 
    str "<li><b>" ; 
    esc (IItem.to_string (item # id)) ; 
    str "</b> &mdash; " ; 
    esc (MFmt.date_of_float (item # time)) ;
    str "</li>"
  ])

let render access = function
  | `Item itid -> render_item access itid

let () = define UrlMe.News.def_home begin fun owid cuid ->
  O.Box.fill (O.decay begin

    let  access = Util.memoize (fun iid -> Run.memo begin
      (* Acting as confirmed self to view items. *)
      let  cuid = ICurrentUser.Assert.is_old cuid in    
      let! inst = ohm_req_or (return None) (MInstance.get iid) in
      CAccess.make cuid iid inst
    end) in

    let  uid = IUser.Deduce.is_anyone cuid in 

    let! items, next = ohm_req_or (return ignore) (MNews.Cache.head ~count:10 uid) in
    let! htmls = ohm (Run.list_filter (render access) items) in 
    let  html  = Html.concat htmls in

    return html

  end)
end
