(* © 2012 RunOrg *)

open Ohm

open MNews_common

let () = 
  Sig.listen MInstance.Signals.on_create begin fun iid ->
    create_backoffice
      ~time:(Unix.gettimeofday ())
      ~payload:(`createInstance (IInstance.decay iid))
  end
