(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

type action = <
  js    : JsCode.t ;
  label : I18n.text ;
  icon  : string ;
> ;;

let make list = 
  List.map (fun (label,icon,js) -> (object
    method js    = js
    method label = label
    method icon  = icon
  end)) list

