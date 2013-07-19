(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module type DEF = sig
  val api : ( (IWhite.t option, unit) Action.request -> Action.response -> Action.response O.run) -> unit
  module Format : Fmt.FMT
  val example : Format.t
  val action : [`Admin] ICurrentUser.id -> Format.t -> (string,string) BatPervasives.result O.run
end

module Make = functor (Def:DEF) -> struct

  let example = Def.Format.to_json_string Def.example 

  let () = Def.api (admin_only begin fun cuid req res ->
    if req # get "sig" <> None then 
      return (Action.json ["example",Json.String example] res)
    else
      let  fail str = return (Action.json ["fail",Json.String str] res) in
      let! json = req_or (fail "Expected JSON") (Action.Convenience.get_json req) in
      let! data = req_or (fail "Invalid JSON") (Def.Format.of_json_safe json) in
      let! result = ohm (Def.action cuid data) in
      match result with 
	| Bad error -> fail error
	| Ok id -> return (Action.json ["ok",Json.String id] res)
  end)

end

let fail format = 
  Printf.ksprintf (fun s -> return (Bad s)) format

let ok format = 
  Printf.ksprintf (fun s -> return (Ok s)) format
