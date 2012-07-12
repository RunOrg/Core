(* © 2012 RunOrg *)

module Rich : Ohm.Fmt.FMT
    
val parse : string -> Rich.t 

val to_html : Rich.t -> Ohm.Html.writer

val length : Rich.t -> int

module OrText : sig

  include Ohm.Fmt.FMT with type t = [ `Rich of Rich.t | `Text of string ]

  val to_html : t -> Ohm.Html.writer

  val length : t -> int

end
