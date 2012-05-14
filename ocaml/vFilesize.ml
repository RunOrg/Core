(* © 2012 RunOrg *)

open Ohm

let format i18n megabytes = 
  let value, unit = 
    if megabytes < 0.005 then
      megabytes *. 1000000., "bytes"
    else if megabytes < 0.5 then 
      megabytes *. 1000., "kilobytes"
    else if megabytes > 1000. then 
      megabytes /. 1000., "gigabytes"
    else
      megabytes, "megabytes"
  in
  Printf.sprintf "%.2f %s" megabytes (I18n.translate i18n (`label unit))

let render megabytes i18n vctx = 
  View.esc (format i18n megabytes) vctx
