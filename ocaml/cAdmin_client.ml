(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Grant an offer to a client --------------------------------------------------------------- *)

let seat_options i18n ctx = 
  List.fold_left (fun ctx (id,info) ->
    ctx
    |> View.str "<option value='"
    |> View.esc (IRunOrg.Offer.to_string (IRunOrg.Offer.decay id))
    |> View.str "'>"
    |> I18n.get i18n (info # label)
    |> View.str "</option>"
  ) ctx MRunOrg.Offer.main

let memory_options i18n ctx = 
  let ctx = View.str "<option value=''></option>" ctx in
  List.fold_left (fun ctx (id,info) ->
    ctx
    |> View.str "<option value='"
    |> View.esc (IRunOrg.Offer.to_string (IRunOrg.Offer.decay id))
    |> View.str "'>"
    |> I18n.get i18n (info # label)
    |> View.str "</option>"
  ) ctx MRunOrg.Offer.memory

let () = CAdmin_common.register UrlAdmin.client_gift begin fun i18n user request response ->

  let select = 

    let title = return (View.esc "Clients") in
    
    let body = 
      return begin 
	View.str "<form action='' method='GET'><select name='seats'>"
	|- seat_options i18n
	|- View.str "</select><select name='memory'>"
	|- memory_options i18n
	|- View.str "</select><button type='submit'>Offrir</button></form>"
      end
    in

    CCore.render ~title ~body response 
  in

  let! cid_str = req_or select (request # args 0) in
  let cid = IRunOrg.Client.of_string cid_str in
   
  let! client = ohm_req_or select (MRunOrg.Client.Backdoor.get cid) in

  let! instance = ohm_req_or select
    (MInstance.get (client.MRunOrg.Client.Data.instance)) 
  in

  let! seats_str = req_or select (request # post "seats") in
  let seats = IRunOrg.Offer.of_string seats_str in
  let! (sid,seat_offer) = req_or select
    (MRunOrg.Offer.check MRunOrg.Offer.main seats) 
  in

  let! memory_str = req_or select (request # post "memory") in
  let memory = if memory_str = "" then None else Some (IRunOrg.Offer.of_string memory_str) in
  let! memory_data = req_or select
    (MRunOrg.Offer.check_opt MRunOrg.Offer.memory memory) 
  in

  let admin = IUser.Deduce.current_is_anyone user in
  let today = MRunOrg.Client.today () in
  let kind  = if 
      client.MRunOrg.Client.Data.offer = Some seats && 
      client.MRunOrg.Client.Data.mem_offer = memory 
    then
      `Renew (object
	method days  = seat_offer # days
	method start = max today client.MRunOrg.Client.Data.last_day
	method seat  = (object
	  method daily  = seat_offer # daily
	  method seats  = seat_offer # seats
	  method offer  = seats
	  method memory = seat_offer # memory
	end)
	method memory = BatOption.map (fun (oid,offer) -> (object
	  method daily  = offer # daily 
	  method offer  = IRunOrg.Offer.decay oid
	  method memory = offer # memory
	end)) memory_data
      end)
    else
      `Upgrade (object
	method days = seat_offer # days
	method seat = (object
	  method daily  = seat_offer # daily
	  method seats  = seat_offer # seats
	  method offer  = seats
	  method memory = seat_offer # memory
	end)
	method memory = BatOption.map (fun (oid,offer) -> (object
	  method daily  = offer # daily 
	  method offer  = IRunOrg.Offer.decay oid
	  method memory = offer # memory
	end)) memory_data
      end)
  in
  let time = Unix.gettimeofday () in
  let name = instance # name in

  let! address = ohm begin 
    if client.MRunOrg.Client.Data.address = ""
    then 
      let! profile = ohm_req_or (return "") $ MInstance.Profile.get client.MRunOrg.Client.Data.instance in
      return $ BatOption.default "" profile # address
    else return client.MRunOrg.Client.Data.address
  end in

  let client = cid in

  let! () = ohm 
    (MRunOrg.Order.give ~admin ~address ~name ~client ~kind ~time) 
  in

  let title = return (View.esc "Clients") in
  
  let body = 
    return begin 
      View.str "<h1>" 
      |- View.esc "Offre accordée!"
      |- View.str "</h1><a href='"
      |- View.esc (UrlAdmin.clients # build)
      |- View.str "'>"
      |- View.esc "Retour à la liste"
      |- View.str "</a>"
    end
  in
  
  CCore.render ~title ~body response   

end

(* Rendering the list of clients ------------------------------------------------------------ *)

let render_item id item = 

  let! instance = ohm_req_or (return None)
    (MInstance.get (item.MRunOrg.Client.Data.instance)) 
  in

  let! user = ohm_req_or (return None)
    (MUser.get (IUser.Assert.can_view (instance # usr)))
  in

  let email = user # email in 

  let! pic = ohm (CPicture.small (instance # pic)) in

  let first_day, last_day, seats, memory, daily = 
    MRunOrg.Client.Data.( item.first_day, item.last_day, item.seats, item.memory, item.daily )
  in

  let name = instance # name in
  let key  = instance # key in
  let light = instance # light in 
  let vertical  = IVertical.to_string (instance # ver) in
  let expired   = last_day < MRunOrg.Client.today () in
  let first_day = MRunOrg.Client.string_of_day first_day in
  let last_day  = MRunOrg.Client.string_of_day last_day  in

  return (Some (
    View.str "<tr><td><img style=\"width:30px\" src=\""
    |- View.esc pic
    |- View.str "\"/></td><td><div style=\"font-weight:bold;line-height:10px\">"
    |- View.str "<a href='"
    |- View.esc (UrlAdmin.client_gift # build id)
    |- View.str "'>"
    |- View.esc name
    |- View.str "</a></div><div style=\"font-size:10px;color:#666\"/>"
    |- View.esc key
    |- View.str ".runorg.com</div></td><td><div style=\"font-size:10px;\">"
    |- begin 
      if expired || light
      then identity 
      else 
	View.esc first_day 
	|- View.str " - "
	|- View.esc last_day
    end
    |- View.str "</div></td><td><code><a href=\"mailto:"
    |- View.esc email 
    |- View.str "\">"
    |- View.esc email 
    |- View.str "</a></code></td><td>"
    |- View.str vertical
    |- View.str "</td><td>"
    |- View.esc (string_of_int seats)
    |- View.str "<img src=\"/public/icon/key.png\"/></td><td>"
    |- View.esc (Printf.sprintf "%.2f Go" (float_of_int memory /. 1000.))
    |- View.str "</td></tr>"
  ))

let render list = 
  let! views = ohm (Run.list_filter (fun (id,item) -> render_item id item) list) in
  return (View.concat views)
  
let () = CAdmin_common.register UrlAdmin.clients begin fun i18n user request response ->
  
  let! all = ohm MRunOrg.Client.Backdoor.get_all in

  let sorted = List.sort (fun (_,a) (_,b) -> MRunOrg.Client.Data.(compare b.first_day a.first_day)) all in

  let! render = ohm (render sorted) in
  
  let title = return (View.esc "Clients") in
  
  let body = 
    return begin 
      View.str "<table style=\"margin:auto\">"
      |- render 
      |- View.str "</table>"
    end
  in

  CCore.render ~title ~body response  

end

