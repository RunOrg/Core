(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Information types --------------------------------------------------------------------------------------- *) 

module Info = struct

  module Album = struct
    module T = struct
      type json t = {
	id : IAlbum.t ;      
	n  : int ;
      }
    end
    include T
    include Fmt.Extend(T)
  end
    
  module Folder = struct
    module T = struct
      type json t = {
	id : IFolder.t ;      
	n  : int ;
      }
    end
    include T
    include Fmt.Extend(T)
  end
    
  module Wall = struct
    module T = struct
      type json t = {
	id : IFeed.t ;      
	n  : int ;
      }
    end
    include T
    include Fmt.Extend(T)
  end

  module People = struct
    module T = struct
      type json t = {
	id     : IGroup.t ;
	n      : int ;
	recent : IAvatar.t list ;
	author : IAvatar.t ;	
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
     ?people : Info.People.t option ;
     ?time   : float = 0.0 ;
     ?show   : bool = false ;
    }
  end
  include T
  include Fmt.Extend(T)
end

(* Database and table -------------------------------------------------------------------------------------- *)

include CouchDB.Convenience.Table(struct let db = O.db "inbox-line" end)(IInboxLine)(Line)
