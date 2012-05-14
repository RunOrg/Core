(* © 2012 RunOrg *)

(** Make sure a provided link is either http:// or https://, treat as http:// if no protocol 
    is specified. This is intended to avoid javascript injection. *)
val secure_link : string -> string

(** Prepare text for rendering as HTML. Newlines are ignored, and links are made clickable. *)
val format_links : string -> string

(** Prepare text for rendering as HTML. Empty lines are turned into paragraph breaks, newlines
    are turned into [<br/>] elements, and links are made clickable. *)
val format : ?icons:(string*string) list -> string -> string

(** Extract and prepare the initial segment of a string for rendering as HTML. The
    algorithm looks for the first space (or newline, or tab) after the length exceeds
    the provided limit, cuts off any content after it and appends [" ..."]. This 
    algorithm does no other formatting. *)
val head : int -> string -> string

(** Prepare text for rendering as text e-mail body. 
    Empty lines are turned into paragraph breaks. *)
val format_mail : string -> string

