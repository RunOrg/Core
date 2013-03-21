(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MDocTask_core
module Can = DMS_MDocTask_can

let id       t = t.Can.id
let iid      t = t.Can.data.E.iid
let process  t = t.Can.data.E.process
let state    t = let (s,_,_) = t.Can.data.E.state in s
let data     t = t.Can.data.E.data
let assignee t = t.Can.data.E.assignee
let notified t = t.Can.data.E.notified
let created  t = t.Can.data.E.created
let updated  t = let (_,a,t) = t.Can.data.E.state in (a,t)
let theState t = t.Can.data.E.state
let finished t = not t.Can.data.E.active
let fields   t = PreConfig_Task.DMS.fields t.Can.data.E.process
let states   t = (PreConfig_Task.DMS.states t.Can.data.E.process) # all
let label    t = PreConfig_Task.DMS.label t.Can.data.E.process

