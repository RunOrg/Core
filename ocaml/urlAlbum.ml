(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR    

let image = object (self)
  inherit rest "album/image"
  method build instance (item : [`Read] IItem.id) = 
    self # rest instance [IItem.to_string item]
end 

let moderate = object (self)
  inherit rest "r/album/moderate"
  method build instance (album :[`Admin] IAlbum.id) (item : IItem.t) = 
    self # rest instance [ 
      IAlbum.to_string album ;
      IItem.to_string item
    ]
end

let home  = ajax [ "home";"albums" ]

