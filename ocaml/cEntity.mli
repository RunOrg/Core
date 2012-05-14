(* © 2012 RunOrg *)

module View : sig

  val root_box : ctx:[`Unknown] CContext.full -> (unit * UrlSegs.root_pages) O.box

end

module Home : sig

  val home_box : MEntityKind.t -> ctx:'a CContext.full -> 'b O.box
  val grants_box :                ctx:'a CContext.full -> 'b O.box
  val calendar_box :              ctx:'a CContext.full -> 'b O.box

end
