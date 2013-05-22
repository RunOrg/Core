(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

let () = UrlAdmin.def_cqrs (admin_only begin fun cuid req res ->
  
  let! db = req_or (return res) (req # get "db") in
  let  db = O.db db in
  
  let! seq = req_or (return res) (req # get "s") in
  let! seq = req_or (return res) (try Some (int_of_string seq) with _ -> None) in

  let url = 
    "http://localhost:5984/" ^ db ^ "/_changes?since=" ^ string_of_int seq ^ "&limit=1000&include_docs=true" 
  in
  
  let json = 
    try let result = Http_client.Convenience.http_get url in 
	let json   = Json.unserialize result in 
	json 	
    with exn -> 
      Json.Object [ "error", Json.String (Printexc.to_string exn) ]
  in
  
  return (Action.jsonp ?callback:(req # get "callback") json res)

end)
