(* © 2012 RunOrg *)

open Ohm

open MNews_common

let () = 
  Sig.listen MRelatedInstance.Signals.after_connect begin fun connection ->
    create_backoffice
      ~time:(Unix.gettimeofday ())
      ~payload:(`networkConnect (connection # relation))
  end
