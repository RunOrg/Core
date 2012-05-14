(* © 2012 RunOrg *)

open Ohm

module Float     = Fmt.Float
module T = struct
  type json t = {
    t       : MType.t ;
    key     : string ;
    name    : string ;
   ?address : string option ;
   ?contact : string option ;
    disk    : Float.t ;
    seats   : int ;
   ?create  : Float.t = Unix.gettimeofday () ;
   ?theme   : string option ;
    usr     : IUser.t ; 
    ver     : IVertical.t ;
    pic     : IFile.t option ;
    site    : string option ;
    desc    : string option ;
   ?install : bool = false ;
   ?version : string = "" ;
   ?light   : bool = true ;
   ?stub    : bool = false ;
   ?white   : IWhite.t option 
  } ;; 
end

include T
include Fmt.Extend(T)
