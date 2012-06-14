(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlStart.def_home begin fun req res -> 

  let uid = 
    match CSession.check req with 
      | `None     -> None
      | `Old cuid -> Some (ICurrentUser.decay cuid) 
      | `New cuid -> Some (ICurrentUser.decay cuid)
  in

  let html = Asset_Start_Page.render (object
    method navbar = (uid,None)
    method back = "" 
    method categories = []
    method url = "" 
  end) in

  CPageLayout.core `Me_Title html res 

end
