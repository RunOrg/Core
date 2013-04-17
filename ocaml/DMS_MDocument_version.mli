(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = <
  number   : int ; 
  filename : string ; 
  size     : float ; 
  ext      : MOldFile.Extension.t ;
  file     : IOldFile.t ; 
  time     : float ;
  author   : IAvatar.t ;
>

val number : int -> t -> t
