(* © 2013 RunOrg *)

open UrlClient.Common

let home, def_home = root "dms"
let () = VNavbar.registerPlugin `DMS Url.home `DMS_Navbar

