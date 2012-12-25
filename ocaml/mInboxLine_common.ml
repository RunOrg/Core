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
	last    "t" : float option ; 
	n           : int ;
	authors "a" : IAvatar.t list 
      }
    end
    include T
    include Fmt.Extend(T)
  end
    
  module Folder = struct
    module T = struct
      type json t = {
	id          : IFolder.t ;    
	last    "t" : float option ; 
	n           : int ;
	authors "a" : IAvatar.t list 
      }
    end
    include T
    include Fmt.Extend(T)
  end
    
  module Wall = struct
    module T = struct
      type json t = {
	id          : IFeed.t ;      
	last    "t" : float option ; 
	n           : int ;
	authors "a" : IAvatar.t list 
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
     ?time   : float = 0.0 ;
     ?show   : bool = false ;
     ?push   : int = 0 ;
    }
  end
  include T
  include Fmt.Extend(T)
end

(* Database and table -------------------------------------------------------------------------------------- *)

include CouchDB.Convenience.Table(struct let db = O.db "inbox-line" end)(IInboxLine)(Line)

(* Helper functinos ---------------------------------------------------------------------------------------- *)

let avatars line = 
  let list = 
    ( match line.Line.album with None -> [] | Some a -> a.Info.Album.authors ) 
    @ ( match line.Line.folder with None -> [] | Some f -> f.Info.Folder.authors )
    @ ( match line.Line.wall with None -> [] | Some w -> w.Info.Wall.authors )
  in
  BatList.sort_unique compare list 
