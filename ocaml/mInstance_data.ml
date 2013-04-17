(* © 2012 RunOrg *)

open Ohm

module Float     = Fmt.Float
module T = struct
  type json t = {
    t       : MType.t ;
    key     : string ;
    name    : string ;
    disk    : Float.t ;
    seats   : int ;
   ?create  : Float.t = Unix.gettimeofday () ;
    usr     : IUser.t ; 
    ver     : IVertical.t ;
    pic     : IOldFile.t option ;
   ?white   : IWhite.t option ;
   ?plugins : IPlugin.t list = [] 
  } ;; 
end

include T
include Fmt.Extend(T)
