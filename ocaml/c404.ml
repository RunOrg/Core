(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let render i18n response = 
  V404.render
    (fun ~title ~body -> CCore.render ~title:(return title) ~body:(return body))
    ?navbar:None ?start:None ?js:None ?js_files:None ?css:None 
    ?theme:(Some ("splash",`RunOrg)) i18n response

let () = CCore.register UrlCore.not_found begin fun i18n req response -> 
  render i18n response
end
