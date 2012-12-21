(* © 2012 RunOrg *)

open Ohm
open BatPervasives

module Tz = struct
  type t = float 
  let gmt = 0.
end

type time = { h : int ; i : int ; s : int }
type date = { y : int ; m : int ; d : int ; t : time option }

(* Subtract the tzoffset from any localtime to get the UTC time *)
let tzoffset, _ = Unix.mktime (Unix.gmtime 0.0) 

let of_compact s = 
  try
    let y = int_of_string (String.sub s 0 4) in
    let m = int_of_string (String.sub s 4 2) in
    let d = int_of_string (String.sub s 6 2) in
    if String.length s = 8 then
      Some { y ; m ; d ; t = None }
    else
      let h = int_of_string (String.sub s 8 2) in
      let i = int_of_string (String.sub s 10 2) in
      let s = int_of_string (String.sub s 12 2) in
      Some { y ; m ; d ; t = Some { h ; i ; s }}
  with _ -> None

let of_iso8601 s = 
  try 
    if String.length s = 8 || String.length s = 14 then
      of_compact s 
    else if String.length s = 10 then
      Scanf.sscanf s "%d-%d-%d" 
	(fun y m d -> Some { y ; m ; d ; t = None }) 
    else
      Scanf.sscanf s "%d-%d-%dT%d:%d:%dZ" 
	(fun y m d h i s -> Some { y ; m ; d ; t = Some { h ; i ; s }})
  with _ -> None

let to_iso8601 d = 
  match d.t with 
    | None -> Printf.sprintf "%4d-%02d-%02d" d.y d.m d.d 
    | Some t -> Printf.sprintf "%4d-%02d-%02dT%02d:%02d:%02dZ" d.y d.m d.d t.h t.i t.s

let to_compact d = 
  match d.t with 
    | None -> Printf.sprintf "%4d%02d%02d" d.y d.m d.d
    | Some t -> Printf.sprintf "%4d%02d%02d%02d%02d%02d" d.y d.m d.d t.h t.i t.s

include Fmt.Make(struct
  type t = date
  let t_of_json = function 
    | Json.String s -> begin 
      match of_iso8601 s with 
	| Some d -> d
	| None -> raise (Json.Error (Printf.sprintf "Unexpected date format : %S" s))
    end
    | _ -> raise (Json.Error "Expected string representation for date") 
  let json_of_t d = Json.String (to_iso8601 d) 
end)

let of_timestamp ts = 
  let tm = Unix.gmtime ts in
  { y = 1900 + tm.Unix.tm_year ; 
    m = 1 + tm.Unix.tm_mon ;
    d = tm.Unix.tm_mday ;
    t = Some {
      h = tm.Unix.tm_hour ;
      i = tm.Unix.tm_min ;
      s = tm.Unix.tm_sec 
    }
  }

let to_timestamp t = 

  let tm_hour, tm_min, tm_sec = match t.t with 
    | None -> 0, 0, 0 
    | Some t -> t.h, t.i, t.s
  in

  let tm = Unix.({ 
    tm_year = t.y - 1900 ; 
    tm_mon = t.m - 1 ;
    tm_mday = t.d ;
    tm_hour ;
    tm_min ;
    tm_sec ;
    (* 3 fields below ignored by mktime *)
    tm_wday = 0 ;
    tm_yday = 0 ;
    tm_isdst = false
  }) in

  let ts_local, _ = Unix.mktime tm in
  ts_local -. tzoffset

let datetime tz year month day hour minute second = 

  let tm = Unix.({ 
    tm_year = year - 1900 ; 
    tm_mon = month - 1 ;
    tm_mday = day ;
    tm_hour = hour ; 
    tm_min = minute ;
    tm_sec = second ;
    (* 3 fields below ignored by mktime *)
    tm_wday = 0 ;
    tm_yday = 0 ;
    tm_isdst = false
  }) in

  let ts_local, _ = Unix.mktime tm in
  of_timestamp (ts_local -. tzoffset +. tz) 

let date y m d = 
  { y ; m ; d ; t = None }

let day_only d = { d with t = None }

let ymd d = d.y, d.m, d.d

let min = { y =    0 ; m =  1 ; d =  1 ; t = None }
let max = { y = 9999 ; m = 12 ; d = 31 ; t = None }
