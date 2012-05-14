(* © 2012 RunOrg *)

val render : 
     'a CContext.full
  -> [<`Admin|`View]  MEntity.t
  -> VDashboard.EntityListItem.t O.run

val block : 
     MEntityKind.t 
  -> ctx:'a CContext.full
  -> 'prefix CDashboard_common.definition O.run
