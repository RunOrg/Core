(* © 2012 RunOrg *)

val entities : 
     ctx:'any CContext.full 
  -> label:Ohm.I18n.text 
  -> ?minitip:Ohm.I18n.text
  -> ('seed -> [ `View ] IEntity.id list) 
  -> ('seed, [ `View ] IEntity.id list) Ohm.Joy.template O.run

