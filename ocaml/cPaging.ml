(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module type MORE_ARGS = sig

  module Key : Fmt.FMT

  type data 

end

module More = functor (Args:MORE_ARGS) -> struct

  module Pager = OhmAjaxShowMore.Make(struct
    include Args
    let fetch ~args = Js.More.fetch ~args
    let send  = Js.More.return
  end)

  type data = Args.data

  class type ['input] source = object
    method list : 
         Args.Key.t option
      -> (Args.data list * Args.Key.t option) O.run

    method more : 
         bctx:'input O.Box.box_context
      -> more:Ohm.View.text option 
      -> list:Args.data list
      -> Ohm.View.html O.run

    method page :
         bctx:'input O.Box.box_context
      -> more:Ohm.View.text option 
      -> list:Args.data list
      -> Ohm.View.html O.run
  end

  class ['input] source' s = object
    val s : 'input source = s
    method page_contents = s # list
    method render_next_page ~bctx ~more ~list = 
      s # more ~bctx ~list ~more:(BatOption.map JsBase.to_event more)
    method render_first_page ~bctx ~more ~list =
      s # page ~bctx ~list ~more:(BatOption.map JsBase.to_event more)
  end

  let box source = Pager.box (new source' (source :> 'a source))
      
end
