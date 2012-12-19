(* © 2012 RunOrg *)

open Ohm

let year yyyy =  
  if yyyy < 15 then 2000 + yyyy else
    if yyyy < 100 then 1900 + yyyy else yyyy

let dmy_of_date date = 
  try 
    let yyyy = year (int_of_string (String.sub date 0 4)) 
    and mm   = int_of_string (String.sub date 4 2)
    and dd   = int_of_string (String.sub date 6 2) in

    Some (dd,mm,yyyy) 

  with _ -> None

let date_of_dmy d m y = 
  Printf.sprintf "%04d%02d%02d" (year y) m d
    
let float_of_date d = 
  try 
    let yyyy = year (int_of_string (String.sub d 0 4)) 
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

  
