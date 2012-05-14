(* © 2012 RunOrg *)

val home_box :
     [< `DashActivities | `DashMembers ]
  -> ctx:'any CContext.full
  -> ('a * UrlSegs.home_pages) O.box O.run
