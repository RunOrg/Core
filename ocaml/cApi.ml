(* © 2012 RunOrg *)

open Ohm
open O
open BatPervasives

let () = Action.register (UrlInstance.free_name) begin fun request response ->

  let name = request # post "name" |> BatOption.default "" in    

  let free = try Run.eval (new CouchDB.init_ctx) (MInstance.free_name name) with _ -> "" in 
  
  Action.json [ "val" , Json_type.Build.string free ] response

end
