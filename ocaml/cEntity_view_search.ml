(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let form iid ctx = 
  
  Joy.begin_object (fun ~who -> who)
    
  |> Joy.append (fun f who -> f ~who) 
      (CMember.Picker.configure iid ~ctx 
	 (fun ~format ~source ->
	   Joy.select ~field:"input" ~format ~source
	     (fun _ init -> None)
	     (fun _ field value -> Ok value))
      )
      
  |> Joy.end_object
      ~html:("",VDirectory.FullPageSearch.render ())
      
let reaction iid ctx = 
  O.Box.reaction "search" begin fun self bctx req res ->
    let form = Joy.create (form iid ctx) (ctx # i18n) (Joy.from_post_json (bctx # json)) in
    match Joy.result form with Bad _ -> return res | Ok aidopt ->
      match aidopt with None -> return res | Some aid -> 
	let segs = bctx # segments in
	let prefix, _ = bctx # args in 
	return (O.Action.javascript 
		  (Js.redirect (UrlR.build (ctx # instance) segs (prefix, Some aid)))
		  res)
  end
    
let renderer iid_opt ctx callback =
  match iid_opt with  
    | None     -> callback (fun _ -> identity)
    | Some iid -> let form = Joy.create (form iid ctx) (ctx # i18n) Joy.empty in
		  let! reaction = reaction iid ctx in
		  callback (fun bctx -> 
		    let url = bctx # reaction_url reaction in
		    Joy.render form url)

