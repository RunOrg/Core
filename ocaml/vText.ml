(* © 2012 RunOrg *)

open Ohm

let format text = 
  Html.str (OhmText.format ~nl2br:true ~skip2p:true ~mailto:true ~url:true text)
