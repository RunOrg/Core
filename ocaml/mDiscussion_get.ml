(* © 2012 RunOrg *)

module Core = MDiscussion_core
module Can  = MDiscussion_can 

type 'a t = 'a Can.t 

let id t = Can.id t

open Core
let (!!) t = Can.data t 

let title   t = (!!t).title
let update  t = (!!t).time
let creator t = (!!t).crea
let iid     t = (!!t).iid
let groups  t = (!!t).gids
let body    t = (!!t).body
let avatars t = (!!t).crea :: (!!t).aids 
let isPM    t = groups t = []

