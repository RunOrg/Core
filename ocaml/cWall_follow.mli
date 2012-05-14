(* © 2012 RunOrg *)

val render_action : bool -> string -> VCore.ActionBoxButton.t

val reaction : 
     ctx:'a CContext.full
  -> feed: 'b MFeed.t
  -> (O.Box.reaction -> 'c O.box) -> 'c O.box

