(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Members.def_home begin fun access -> 
  O.Box.fill $ O.decay begin 

    Asset_Group_List.render (object
      method create = None
      method isMember = []
      method isNotMember = []
    end) 
  end
end

