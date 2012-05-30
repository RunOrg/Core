| `Date t -> 
  let t = Unix.localtime t in
  Printf.sprintf "%d %s %d" 
    (t.Unix.tm_mday)
    [| "Janvier" ; "Février" ; "Mars" ; "Avril" ; "Mai" ; "Juin" ; "Juillet" ;
       "Août" ; "Septembre" ; "Octobre" ; "Novembre" ; "Décembre" |].(t.Unix.tm_mon) 
    (t.Unix.tm_year + 1900) 

| `DateRelative (time,now) -> 
  let default () = 
    let dnow  = Unix.gmtime now and dtime = Unix.gmtime time in
    let month =     
      [| "Janvier" ; "Février" ; "Mars" ; "Avril" ; "Mai" ; "Juin" ; "Juillet" ;
	 "Août" ; "Septembre" ; "Octobre" ; "Novembre" ; "Décembre" |].(dtime.Unix.tm_mon) 
    in
    let day   = string_of_int dtime.Unix.tm_mday in
    let year  = string_of_int (1900 + dtime.Unix.tm_year) in  
    if dnow.Unix.tm_year = dtime.Unix.tm_year then 
      day ^ " " ^ month
    else
      day ^ " " ^ month ^ " " ^ year
  in
  if now > time then
    if now -. time < 60.0 then 
      "Il y a quelques instants"
    else if now -. time < 120.0 then
      "Il y a une minute"
    else if now -. time < 3600.0 then 
      "Il y a " ^ (string_of_int (int_of_float ((now -. time) /. 60.))) ^ " minutes"
    else if now -. time < 7200.0 then
      "Il y a une heure"
    else if now -. time < 86400.0 then
      "Il y a " ^ (string_of_int (int_of_float ((now -. time) /. 3600.))) ^ " heures"
    else 
      default () 
    else default ()


