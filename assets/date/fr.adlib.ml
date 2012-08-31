| `Date t -> 
  let t = Unix.localtime t in
  Printf.sprintf "%d %s %d" 
    (t.Unix.tm_mday)
    [| "Janvier" ; "Février" ; "Mars" ; "Avril" ; "Mai" ; "Juin" ; "Juillet" ;
       "Août" ; "Septembre" ; "Octobre" ; "Novembre" ; "Décembre" |].(t.Unix.tm_mon) 
    (t.Unix.tm_year + 1900) 

| `WeekDate t -> 
  let t = Unix.localtime t in
  Printf.sprintf "%s %d %s %d"
    [| "Dimanche" ; "Lundi" ; "Mardi" ; "Mercredi" ; "Jeudi" ; 
       "Vendredi" ; "Samedi"  |].(t.Unix.tm_wday)
    (t.Unix.tm_mday)
    [| "Janvier" ; "Février" ; "Mars" ; "Avril" ; "Mai" ; "Juin" ; "Juillet" ;
       "Août" ; "Septembre" ; "Octobre" ; "Novembre" ; "Décembre" |].(t.Unix.tm_mon) 
    (t.Unix.tm_year + 1900) 

| `ShortWeekDate (time,now) -> 
  let t = Unix.localtime time in
  let now = Unix.localtime now in 
  Printf.sprintf "%s %02d/%02d%s"
    [| "Dim" ; "Lun" ; "Mar" ; "Mer" ; "Jeu" ; 
       "Ven" ; "Sam"  |].(t.Unix.tm_wday)
    (t.Unix.tm_mday)
    (t.Unix.tm_mon + 1) 
    (if now.Unix.tm_year = t.Unix.tm_year then "" else "/" ^ string_of_int (t.Unix.tm_year - 100)) 

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

| `FullDate time ->   
  let t = Unix.localtime time in
  Printf.sprintf "%02d/%02d/%04d" 
    t.Unix.tm_mday (t.Unix.tm_mon + 1) (t.Unix.tm_year + 1900)
