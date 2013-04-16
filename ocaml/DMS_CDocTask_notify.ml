(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module MDocTask = DMS_MDocTask

let () = MDocTask.Notify.define begin fun uid u t info ->
  return None
end
