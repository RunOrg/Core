(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Url = DMS_Url
module MRepository = DMS_MRepository

let () = CClient.define Url.def_home begin fun access -> 
  O.Box.fill $ O.decay begin 
    return (Html.str "")
  end 
end
