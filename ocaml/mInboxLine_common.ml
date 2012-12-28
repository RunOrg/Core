(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Information types --------------------------------------------------------------------------------------- *) 

module Info = struct

  module Album = struct
    module T = struct
      type json t = {
	id          : IAlbum.t ;      
       ?last    "l" : (float * IAvatar.t) option ; 
	n           : int ;
      }
    end
    include T
    include Fmt.Extend(T)
  end
    
  module Folder = struct
    module T = struct
      type json t = {
	id          : IFolder.t ;    
       ?last    "t" : (float * IAvatar.t) option ; 
	n           : int ;
      }
    end
    include T
    include Fmt.Extend(T)
  end
    
  module Wall = struct
    module T = struct
      type json t = {
	id          : IFeed.t ;      
       ?last    "t" : (float * IAvatar.t) option ; 
	n           : int ;
      }
    end
    include T
    include Fmt.Extend(T)
  end

end

(* Actual inbox line type ----------------------------------------------------------------------------------- *)

module Line = struct
  module T = struct
    type json t = {
      owner  : IInboxLineOwner.t ;
     ?album  : Info.Album.t option ;
     ?folder : Info.Folder.t option ; 
     ?wall   : Info.Wall.t option ;
     ?last   : (float * IAvatar.t) option ; 
     ?show   : bool = false ;
     ?push   : int = 0 ;
    }
  end
  include T
  include Fmt.Extend(T)
end

(* Database and table -------------------------------------------------------------------------------------- *)

include CouchDB.Convenience.Table(struct let db = O.db "inbox-line" end)(IInboxLine)(Line)
