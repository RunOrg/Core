(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlClientHelper

let instance ins crid_opt = 
  UrlR.build ins
    O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.home_pages ++ UrlSegs.chat_id)
    ((((),`Home),`Chat),BatOption.map IChat.Room.decay crid_opt)

let entity ins eid crid_opt = 
  UrlR.build ins
    O.Box.Seg.(UrlSegs.(root ++ root_pages ++ entity_id ++ entity_tabs ++ chat_id))
    (((((),`Entity),Some eid),`Chat),BatOption.map IChat.Room.decay crid_opt)
