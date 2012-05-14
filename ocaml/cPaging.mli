(* © 2012 RunOrg *)

module type MORE_ARGS = sig

  module Key : Ohm.Fmt.FMT

  type data 

end

module More : functor (Args:MORE_ARGS) -> sig

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

  type data = Args.data

  val box : 'a #source -> 'a O.box

end
