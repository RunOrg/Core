(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

let box ~(ctx:'any CContext.full) ~wall =
  let child = "n" in
  O.Box.node 
    begin fun input (prefix,_) -> 	 
      begin 
	let config = object
	  method react  = true
	  method chat a = Some (UrlR.build (ctx # instance) 
				  O.Box.Seg.(input # segments ++ UrlSegs.chat_id)
				  ((prefix,`Chat),BatOption.map IChat.Room.decay a))
	end in
	return [child, CWall.full_nested_box ~ctx ~wall ~config]
      end ,
	return
	  (VEntity.wall ~content:(input # name,child) ~i18n:(ctx # i18n))
    end
