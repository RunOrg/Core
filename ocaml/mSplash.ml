(* © 2012 RunOrg *)

open Ohm
open Ohm.Util 
open Ohm.Universal
open BatPervasives

module MyDB = MModel.ConfigDB

module Data = Fmt.Make(struct
  type json t = <
    tests : (string * bool) assoc ;
    paths : (string * (string * <
      view  : string ;
      title : string
    >) assoc) assoc 
  > 
end)

module MyTable = CouchDB.Table(MyDB)(Id)(Data)

include Data

let _config_id = Id.of_string "splash"

let _default = object
  method tests = []
  method paths = []
end

let _load_splash = 
  if Util.role = `Put then begin
    match Util.get_resource_contents "splash.json" with 
      | None -> log "Splash.import : FAIL : could not open resource"
      | Some json ->
	match 
	  try Some (Json_io.json_of_string ~recursive:true json) 
	  with exn -> 
	    log "FAIL : error %s while parsing splash resource" (Printexc.to_string exn) ; None
	with None -> () | Some config ->
	  try 
	    let _ = Run.eval (new CouchDB.init_ctx) $ 
	      MyDB.transaction _config_id (MyDB.insert config) in
	    log "Splash.import : loaded splash.json"
	  with _ -> log "Splash.import : FAIL : could not write resource splash.json"
  end

let config = 
  log "Loading splash site configuration" ;
  match MyTable.get _config_id |> Run.eval (new CouchDB.init_ctx) with
    | Some splash -> splash
    | _           -> _default

let public_tests = Array.of_list ("default" :: List.map fst (List.filter snd (config # tests)))
let admin_tests  = Array.of_list ("default" :: List.map fst (config # tests)  )

let test_of_session ~admin session = 
  let tests = if admin then admin_tests else public_tests in
  let test_count = Array.length tests in
  let hash = Hashtbl.hash session mod test_count in 
  tests.(hash) 
