(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
      aid    : IAvatar.t ;
      ilid   : IInboxLine.t ; 
      album  : (int * int) ;
      folder : (int * int) ;
      wall   : (int * int) ;
      seen   : float ; 
      last   : float ; 
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "inbox-line-view" end)(IInboxLine.View)(Data)
