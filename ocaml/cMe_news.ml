(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let render_item access itid = 
  let! iid = ohm_req_or (return None) $ MItem.iid itid in 
  let! access = ohm_req_or (return None) $ access iid in 
  let! item = ohm_req_or (return None) $ MItem.try_get access itid in 
  let! now  = ohmctx (#time) in
  let! aid  = req_or (return None) $ MItem.author_by_payload (item # payload) in 
  let! author = ohm $ CAvatar.mini_profile aid in
  let! name = req_or (return None) (author # nameo) in 
  let! html = ohm $ Asset_News_Item.render (object
    method body = "Lorem ipsum"
    method name = name
    method date = (item # time, now)
    method url  = ""
    method pic  = author # pico
  end) in
  return (Some html)

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

    let! fresh, items, next = ohm (MNews.Cache.head ~count:10 uid) in
    let! htmls = ohm (Run.list_filter (render access) items) in 
    let  html  = Html.concat htmls in

    return html

  end)
end
