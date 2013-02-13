(* © 2013 RunOrg *)

open UrlClient.Common

let home, def_home = root "dms/repos"
let () = VNavbar.registerPlugin `DMS home `DMS_Navbar

let create, def_create = child def_home "dms/repo/create"
