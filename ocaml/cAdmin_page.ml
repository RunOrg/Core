(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let () = CAdmin_common.register UrlAdmin.index begin fun i18n user request response ->

  return (Action.html (fun js ctx -> VAdmin.Index.render js i18n ctx) response)

end
  
  
