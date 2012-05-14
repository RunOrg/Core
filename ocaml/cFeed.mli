(* © 2012 RunOrg *)

type 'a cache
val make_cache : 'a CContext.full -> 'a cache

module CWall : sig 
  val render_item : 'a cache -> MItem.item -> Ohm.View.html option O.run
end

val render : 'a cache -> MNews.t -> Ohm.View.html option O.run

val home_box : ctx:'a CContext.full -> 'b O.box
