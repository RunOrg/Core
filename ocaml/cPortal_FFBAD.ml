(* © 2012 RunOrg *) 

let rename path = "FFBAD/" ^ OhmStatic.canonical path

let _ = OhmStatic.export 
  ~server:  O.core 
  ~title:   "FFBAD"
  Static_FFBAD.site
