(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let home,     def_home     = O.declare O.secure "admin" A.none
let active,   def_active   = O.declare O.secure "admin/active" (A.o A.int)
let public,   def_public   = O.declare O.secure "admin/public" (A.o A.int) 
let instance, def_instance = O.declare O.secure "admin/instance" (A.r IInstance.arg)
let mksearch, def_mksearch = O.declare O.secure "admin/instance/mksearchable" (A.r IInstance.arg)
let stats,    def_stats    = O.declare O.secure "admin/stats" A.none
let getStats, def_getStats = O.declare O.secure "admin/stats/get" (A.r A.int) 
let api,      def_api      = O.declare O.secure "admin/api" A.none
let unsbs,    def_unsbs    = O.declare O.secure "admin/unsbs" A.none
let insts,    def_insts    = O.declare O.secure "admin/insts" A.none

module API = UrlAdmin_API
