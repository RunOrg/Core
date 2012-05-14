(* © 2012 RunOrg *)

open MVote_common

let id        t = t.id
let creator   t = t.data.Vote.creator
let created   t = t.data.Vote.time
let anonymous t = t.data.Vote.anonymous
