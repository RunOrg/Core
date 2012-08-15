(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module T = struct

  type json t = {
    aid         : IAvatar.t ;
    iid         : IInstance.t ;
    kind    "k" : IProfileForm.Kind.t ;
    name    "n" : MRich.OrText.t ;
    hidden  "h" : bool ;
    created "c" : float * IAvatar.t ;
    updated "u" : (float * IAvatar.t) option 
  }

end

include T
include Fmt.Extend(T)

