(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define ~back:(Action.url UrlClient.Members.home) UrlClient.Profile.def_home begin fun access -> 

  let! aid = O.Box.parse IAvatar.seg in
      
  O.Box.fill $ O.decay begin

    Asset_Profile_Page.render (object
    end)

  end
end
