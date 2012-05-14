(* © 2012 RunOrg *)

val ask : 
     'a CContext.full
  -> Ohm.I18n.text
  -> ((O.Box.reaction -> 'b O.box) -> 'b O.box)
  -> (O.Box.reaction -> 'b O.box)
  -> 'b O.box
