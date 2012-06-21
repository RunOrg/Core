(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Events.def_home begin fun access -> 
  O.Box.fill $ O.decay begin 
    let! list = ohm $ MEntity.All.get_by_kind access `Event in
    let! list = ohm $ Run.list_map begin fun entity -> 
      return (object
	method coming = 0 
	method date = None
	method pic = None
	method status = "" 
	method title = "" 
      end)
    end list in 
    Asset_Event_ListPrivate.render (object
      method list = list
      method url_new     = "#"
      method url_options = Some "#" 
    end) 
  end
end
