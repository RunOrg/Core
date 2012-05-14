(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives
open O

open CDashboard_common

let async ~(ctx:[`IsAdmin] CContext.full) = 
  O.Box.reaction "contacts" begin fun self bctx req res ->

    (* Obtained through simulated annealing *)
    let durations = [
      `d_5min , 60. *. 5.         , 1. ;
      `d_1h   , 3600.             , 0.76109103 ;
      `d_2h   , 3600. *. 2.       , 0.42295812 ;
      `d_3h   , 3600. *. 3.       , 0.26899204 ;
      `d_4h   , 3600. *. 4.       , 0.20923702 ;
      `d_5h   , 3600. *. 5.       , 0.14858146 ;
      `d_6h   , 3600. *. 6.       , 0.14846461 ;
      `d_today, 3600. *. 24.      , 0.14775664 ;
      `d_2days, 3600. *. 24. *. 2., 0.07381054 ;
      `d_3days, 3600. *. 24. *. 3., 0.04202811 ;
      `d_week , 3600. *. 24. *. 7., 0.03326882 ;
    ] in

    let count = 20 in

    let instance = IIsIn.instance (ctx # myself) in
    let! latest, next = ohm $
      MAvatar.Pending.get_latest_confirmed ~count instance
    in

    let now = Unix.gettimeofday () in

    let scores = BatList.filter_map (fun (tag,duration,multiplier) -> 
      let threshold = now -. duration in
      let count = List.length (List.filter (fun (_,t) -> t > threshold) latest) in
      if count = 0 then None else Some (
	tag,
	threshold,
	count,
	float_of_int count *. multiplier
      )
    ) durations in

    let sorted = List.sort (fun (_,_,_,a) (_,_,_,b) -> compare b a) scores in
    let best = match sorted with [] -> None | h :: _ -> Some (
      let tag, threshold, n, _ = h in
      let more = match next with None -> false | Some (time,_) ->
	n = count && threshold < time
      in
      tag, n, more	
    ) in
      
    let stats = BatOption.map (fun (tag,n,more) -> (object
      method label =
	let singular = match tag with 
	  | `d_5min  -> "5min"
	  | `d_1h    -> "1h"
	  | `d_2h    -> "2h"
	  | `d_3h    -> "3h"
	  | `d_4h    -> "4h"
	  | `d_5h    -> "5h"
	  | `d_6h    -> "6h"
	  | `d_today -> "today"
	  | `d_2days -> "2days"
	  | `d_3days -> "3days"
	  | `d_week  -> "week"
	in
	let plural = if n = 1 then singular ^ ".singular" else singular in
	`label ("contacts.since."^plural) 
      method number = n
      method more   = more
    end)) best in

    let data = object
      method stats = stats
    end in

    return (Action.json
	      (Js.Html.return 
		 (VDashboard.Contacts.render data (ctx # i18n)))
	      res)
      
  end

let block ~ctx = 

  match CClient.is_admin (ctx # myself) with 
    | None -> return (callback_return None)
    | Some isin -> 
      let ctx = CContext.evolve_full isin ctx in 
      return (fun callback -> 
	let! contacts = async ~ctx in
	callback (Some (fun bctx (prefix,_) ->
	  element
	    ~icon:VIcon.chart_line
	    ~url:(UrlR.build (ctx # instance) (bctx # segments) (prefix,`Contacts))
	    ~base:"contacts"
	    ~load:(Some (bctx # reaction_url contacts))
	    ~green:None
	    ~access:`Admin
	    ~hasdesc:false
	))
      )  
