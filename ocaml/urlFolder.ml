(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR    

let moderate = object (self)
  inherit rest "r/folder/moderate"
  method build instance (folder:[`Admin] IFolder.id) (item : IItem.t) = 
    self # rest instance [ 
      IFolder.to_string folder ;
      IItem.to_string item
    ]
end

