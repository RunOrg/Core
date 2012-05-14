(* © 2012 RunOrg *)

open Ohm

let of_semantics : [<`event|`group] -> I18n.text = function 
  | `event -> (`label "entity.tab.event.participants") 
  | `group -> (`label "entity.tab.group.participants") 

let entity_kind_root = function
  | `Event -> "event"
  | `Group -> "group"
  | `Subscription -> "subscription"
  | `Forum -> "forum"
  | `Poll -> "poll"
  | `Album -> "album"
  | `Course -> "course"

let of_status : MMembership.Status.t -> I18n.text = function 
  | `Unpaid    -> `label "membership.status.unpaid"
  | `Member    -> `label "membership.status.member"
  | `Pending   -> `label "membership.status.pending"
  | `Invited   -> `label "membership.status.invited"
  | `Declined  -> `label "membership.status.declined"
  | `NotMember -> `label "membership.status.not-member" 

let of_entity_kind : [`single | `plural] -> MEntityKind.t -> I18n.text = fun n k ->
  let l = entity_kind_root k in 
  (`label ("entity.type." ^ l ^ (if n = `plural then "s" else "")))

let create_entity_kind : MEntityKind.t -> I18n.text = fun k ->
  let l = entity_kind_root k in 
  `label (l^".create")

let empty_entity_list : MEntityKind.t -> I18n.text = fun k ->
  let l = entity_kind_root k in 
  `label (l^".list.empty")

let past_entity_list : MEntityKind.t -> I18n.text = fun k ->
  let l = entity_kind_root k in 
  `label (l^".list.past")

let entity_chooser_title : MEntityKind.t -> I18n.text = fun k ->
  let l = entity_kind_root k in 
  `label (l^".create.chooser.title")

let of_payment_method : MAccountLine.Method.t -> I18n.text = fun k ->
  `label ("accounting.method."^(match k with 
    | `Cash -> "cash"
    | `Transfer -> "transfer"
    | `AutoBill -> "auto-bill"
    | `Card -> "card"
    | `Paypal -> "paypal"
    | `Cheque -> "cheque"
    | `Other -> "other"))
