(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let render_action blocked url = object
  method label = `label (if blocked then "wall.follow.start" else "wall.follow.stop")
  method js    = Js.runFromServer url
  method img   = if blocked then VIcon.lightbulb_off else VIcon.lightbulb
end


let reaction ~ctx ~feed = 
  O.Box.reaction "follow" begin fun reaction bctx _ response ->
    
    let feed = `Feed (IFeed.decay (MFeed.Get.id feed)) in
    let! self = ohm (ctx # self) in
    let! blocked = ohm (MBlock.is_blocked self feed) in
    
    let! () = ohm (
      if blocked then MBlock.unblock self feed
      else            MBlock.block   self feed
    ) in
    
    let blocked = not blocked in (* We just reversed this ! *)
    let url     = bctx # reaction_url reaction in
    
    let view = VCore.ActionBoxButton.render (render_action blocked url) (ctx # i18n) in
    
    return $ O.Action.javascript (Js.replaceWith "a" view) response
      
  end
    
