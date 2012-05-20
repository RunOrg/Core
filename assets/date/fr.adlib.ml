| `Date t -> 
  let t = Unix.localtime t in
  Printf.sprintf "%d %s %d" 
    (t.Unix.tm_mday)
    [| "Janvier" ; "Février" ; "Mars" ; "Avril" ; "Mai" ; "Juin" ; "Juillet" ;
       "Août" ; "Septembre" ; "Octobre" ; "Novembre" ; "Décembre" |].(t.Unix.tm_mon) 
    (t.Unix.tm_year + 1900) 
