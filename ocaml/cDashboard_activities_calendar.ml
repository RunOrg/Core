(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives
open O

open CDashboard_common

module Entities = CDashboard_entities

let async ~ctx =
  let name = "calendar" in
  O.Box.reaction name begin fun self bctx req res ->

    let! entities = ohm $ MEntity.All.get_future ctx in 
    
    let entities = List.rev entities in

    let entities_with_dates = BatList.filter_map begin fun entity -> 
      match MEntity.Get.date entity with None -> None | Some day -> 
	match MFmt.float_of_date day with None -> None | Some day -> 
	  let day, _ = View.extract (VDate.wmdy_render day (ctx # i18n)) in
	  Some (day,entity) 
    end entities in 

    let by_dates = 
      BatList.group (fun a b -> compare (fst a) (fst b)) entities_with_dates 
      |> BatList.filter_map (function
	  | [] -> None
	  | ((day,_) :: _) as l -> Some (day, List.map snd l))
    in

    let render_day (day,entities) = 
      let! list = ohm $ Run.list_map (Entities.render ctx) entities in
      return (object
	method day = day
	method content i vc = VDashboard.EntityList.render
	  (object
	    method list = list
	    method rest = None 
	   end) i vc
      end)
    in

    let! days = ohm $ Run.list_map render_day by_dates in 
    let  view = VDashboard.Calendar.render days (ctx # i18n) in
      
    return (Action.json (Js.Html.return view) res)

  end

let block ~ctx = 
  
  return (fun callback -> 
    let! inner = async ~ctx in
    callback (Some (fun bctx (prefix,_) ->
      element
	~icon:(VIcon.calendar)
	~url:(UrlR.build (ctx # instance) (bctx # segments) (prefix,`Calendar))
	~base:("calendar")
	~load:(Some (bctx # reaction_url inner))
	~green:None
	~access:`Public
	~hasdesc:false
    ))
  )  
