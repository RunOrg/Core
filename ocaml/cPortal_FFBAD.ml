(* © 2012 RunOrg *) 

let rename path = "portals/FFBAD/" ^ OhmStatic.canonical path

let _ = OhmStatic.export 
  ~rename
  ~server:  O.core 
  ~title:   "FFBAD"
  Static_FFBAD.site
