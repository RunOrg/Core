(* © 2012 RunOrg *)

(** VIncentive blocks appear in sidebars to provoke actions. *)

(** An incentive item (several of them in a block) contains a title, a picture,
    a body text and a target-url. *)
type item = <
  target : string ;
  title  : Ohm.I18n.text ;
  image  : string ;
  text   : Ohm.I18n.text
>

(** Renders a proper block (with a separator at the top) if at least one item
    is present, does nothing otherwise. *)
val render_block : item list -> Ohm.I18n.t -> Ohm.View.html
