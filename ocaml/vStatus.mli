(* © 2012 RunOrg *)

type t 
val admin   : t
val member  : t 
val contact : t

(** Extract a CSS class representing the user status. Possibilities are
    ["status-admin"], ["status-member"] and ["status-contact"]. *)
val css_class : t -> string

(** Construct a label representing the user status. Possibilities are
    ["user-status-admin"], ["user-status-member"] and ["user-status-contact"] *)
val label : t -> Ohm.I18n.text
