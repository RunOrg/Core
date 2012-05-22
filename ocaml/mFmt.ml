(* © 2012 MRunOrg *)

open Ohm

module Gender = Fmt.Make(struct
  type json t = [`m|`f]
end)

let dmy_of_date date = 
  try 
    let yyyy = int_of_string (String.sub date 0 4) 
    and mm   = int_of_string (String.sub date 4 2)
    and dd   = int_of_string (String.sub date 6 2) in
    Some (dd,mm,yyyy) 
  with _ -> None

let date_of_dmy d m y = 
  Printf.sprintf "%04d%02d%02d" y m d
    
let format_amount = 
  function `Fr ->
    (fun amount ->
      let out = Printf.sprintf "%.2f" (float_of_int amount /. 100.) in
      let _, string = BatString.replace ~str:out ~sub:"." ~by:"," in
      string
    )

let unformat_amount = 
  function `Fr ->
    (fun string ->
      try 
	let _, clean = BatString.replace ~str:string ~sub:"," ~by:"." in
	let float = float_of_string clean in
	Some (int_of_float (float *. 100.))
      with _ -> None)

let format_date =
  function `Fr -> 
    (fun date ->
      try 
	let yyyy = int_of_string (String.sub date 0 4) 
	and mm   = int_of_string (String.sub date 4 2)
	and dd   = int_of_string (String.sub date 6 2) in
	Some (Printf.sprintf "%02d / %02d / %04d" dd mm yyyy)
      with _ -> None)

let unformat_date = 
  function `Fr ->
    (fun string ->
      try 
	let split = List.map int_of_string (BatString.nsplit string " / ") in
	match split with 
	  | [ dd ; mm ; yyyy ] -> Some (Printf.sprintf "%04d%02d%02d" yyyy mm dd )
	  | _ -> None
      with _ -> None)

(* Internal : yyyymmdd *)
let date lang = 
  let format = format_date lang and unformat = unformat_date lang in 
  let to_json date = Json_type.Build.optional Json_type.Build.string (format date) in
  let of_json json = try unformat (Json_type.Browse.string json) with _ -> None in  
  Ohm.Fmt.({ to_json ; of_json })

let float_of_date d = 
  try 
    let yyyy = int_of_string (String.sub d 0 4) 
    and mm   = int_of_string (String.sub d 4 2)
    and dd   = int_of_string (String.sub d 6 2) in

    Some (fst (Unix.mktime {
      Unix.tm_sec = 0 ;
      Unix.tm_min = 0 ;
      Unix.tm_hour = 0 ;
      Unix.tm_mday = dd ;
      Unix.tm_mon  = mm - 1 ;
      Unix.tm_year = yyyy - 1900 ;
      Unix.tm_isdst = false ;
      Unix.tm_wday  = 0 ;
      Unix.tm_yday  = 0 
    }))
  with _ -> None

let date_of_float f = 
  let t = Unix.localtime f in
  Printf.sprintf "%04d%02d%02d" 
    (t.Unix.tm_year + 1900) 
    (t.Unix.tm_mon  + 1) 
    (t.Unix.tm_mday)

let date_string lang d = 
  match (date lang).Fmt.to_json d with Json_type.String s -> s | _ -> ""
  
