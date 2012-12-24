(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module Count = Fmt.Make(struct
  type json t = <
    old_count "o" : int ;
    new_count "n" : int ;
  >
end)

let count o n = object
  method old_count = o
  method new_count = n
end

let view c = 
  count (c # new_count) (c # new_count) 
      
module Data = struct
  module T = struct
    type json t = {
      aid    : IAvatar.t ;
      ilid   : IInboxLine.t ; 
      album  : Count.t ;
      folder : Count.t ;
      wall   : Count.t ; 
      seen   : float ; 
      last   : float ; 
    }
  end
  include T
  include Fmt.Extend(T)
end

let default ilid aid = Data.({
  ilid   = IInboxLine.decay ilid ;
  aid    = IAvatar.decay aid ;
  album  = count 0 0 ;
  folder = count 0 0 ;
  wall   = count 0 0 ;
  seen   = 0.0 ;
  last   = 0.0 ;
})

let view now line = Data.({
  line with 
    album  = view line.album ;
    folder = view line.folder ;
    wall   = view line.wall ;
    seen   = now ;
})

include CouchDB.Convenience.Table(struct let db = O.db "inbox-line-view" end)(IInboxLine.View)(Data)

let update ilid aid line = 
  Tbl.replace (IInboxLine.View.make ilid aid) begin fun view_opt ->
    let view = BatOption.default (default ilid aid) view_opt in 
    let count old f x = count (old # old_count) (BatOption.default 0 (BatOption.map f x)) in
    Data.({ view with 
      album  = count view.album  (fun a -> a.Info.Album.n)  line.Line.album ;
      folder = count view.folder (fun f -> f.Info.Folder.n) line.Line.folder ;
      wall   = count view.wall   (fun w -> w.Info.Wall.n)   line.Line.wall ;
      last   = line.Line.time ;
    })
  end
