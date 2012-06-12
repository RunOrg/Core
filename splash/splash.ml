open Common

let code = 
  String.concat "" Pages.pages 

let _ = 
  try 
    let code = 
      "open Ohm open Ohm.Universal open BatPervasives " 
      ^ code  
      ^ WithSections.included  
    in
    let path = "../_build/splash.ml" in
    let chan = open_out_bin path in
    output_string chan code ;
    close_out chan ;
    print_endline "Generated !" 
  with exn -> 
    print_endline (Printexc.to_string exn) 
