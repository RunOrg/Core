(* © 2012 RunOrg *)

(** Render a percentage table. 
    @param total The number that appears next to 100% on the total line.
    @param stats A list of [(label,subtotal)] entries to be displayed in the table.
*)   
val render : 
     total:int
  -> stats:(Ohm.I18n.text * int) list
  -> Ohm.I18n.t
  -> Ohm.View.Context.box Ohm.View.t
