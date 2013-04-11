(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let () = define UrlMe.Notify.def_settings begin fun owid cuid -> 
  O.Box.fill begin
    return ignore
  end
end
