(* © 2012 RunOrg *)

type access = 
  [ `Entity of [ `Admin | `Invite | `Registered | `Normal | `Public ] 
  | `EntityPage of [ `Admin | `Registered | `Normal | `Public ]
  | `Page of [ `Admin | `Normal | `Public ]
  | `Block of [ `Admin | `Normal | `Public ] 
  ]

val render : access option -> Ohm.I18n.t -> Ohm.View.html 

val render_right : access option -> Ohm.I18n.t -> Ohm.View.html 
