(* © 2013 RunOrg *)

open Ohm

module Send = CNotif_send

let link nid naid owid = 
  Action.url UrlMe.Notify.link owid ( nid, MNotif.get_token nid, naid )
