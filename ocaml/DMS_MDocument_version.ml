(* © 2013 RunOrg *)

open Ohm

include Fmt.Make(struct 
  type json t = <
    number   : int ; 
    filename : string ; 
    size     : float ; 
    ext      : MFile.Extension.t ;
    file     : IFile.t ; 
    time     : float ;
    author   : IAvatar.t ;
  >
end)

let number n t = object
  method number   = n 
  method filename = t # filename
  method size     = t # size
  method ext      = t # ext
  method file     = t # file
  method time     = t # time
  method author   = t # author
end
