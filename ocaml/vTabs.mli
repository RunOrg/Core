(* © 2012 RunOrg *)

(** Render tabs. 
    @param vertical Render tabs vertically instead of horizontally?
    @param list The list of all tabs, with id, url and label.
    @param selected The id of the selected tab.
    @param i18n Internationalization object.
*)
val render : 
     vertical:bool
  -> list:('id * string * Ohm.I18n.text) list 
  -> selected:'id
  -> i18n: Ohm.I18n.t
  -> Ohm.View.Context.box Ohm.View.t
  
