(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let url = 
  "http://pacemkr.com/beat/5BlLq0012Kc/11115e777259e9a6f5ff142ed8041d46"

let active = 
  O.environment = `Prod

let replace str pat repl = 
  String.concat repl (BatString.nsplit str pat)

let pid = Unix.getpid () 

let send ~nature ?alert id format = 
  let id = List.fold_left (fun s (k,v) -> replace s k v) id [
    "$pid", string_of_int pid ;
    "$role", (match O.role with 
      | `Put -> "PUT"
      | `Reset -> "RESET"
      | `Bot -> "BOT"
      | `Web -> "WEB") ;
  ] in
  Printf.ksprintf begin fun detail ->
    let json = Json.Object [
      "detail",  Json.String detail ;
      "alert",   Json.of_opt Json.of_int alert ;
      "nature",  Json.String nature ;
      "id",      Json.String id ;
      "minimum", Json.Int 1 ;
    ] in
    let payload = Json.serialize (Json.Array [json]) in 
    if active then 
      let _ = Http_client.Convenience.http_post url ["json", payload] in
      () 
  end format

let every duration f = 
  let last = ref 0. in
  let count = ref 0 in
  fun arg ->
    incr count ; 
    let now = Unix.gettimeofday () in
    let diff = now -. !last in 
    if diff > duration then ( 
      last := now ; 
      f arg (float_of_int !count *. 60. /. diff) ; 
      count := 0
    ) 

(* The web site heartbeat *)

let () = 
  let render = every 60. begin fun (mode,url) freq -> 
    send ~nature:"Web Server Instances" ~alert:10 "#$pid"
      "%s %s (%.2f / minute)" mode url freq 
  end in  
  let! info = Sig.listen O.on_action in
  return (render info) 

(* The actual bot heartbeat *)

let () =
  let render = every 300. begin fun stats _ -> 
    send ~nature:"Async Bot" ~alert:10 "#$pid" 
      "Running: %d ; pending : %d ; failed : %d"
      (stats # running) (stats # pending) (stats # failed) 
  end in
  O.async # periodic 1 begin 
    let! () = ohm $ return () in
    let! stats = ohm $ O.async # stats in 
    let  () = render stats in 
    return (Some 300.)
  end

