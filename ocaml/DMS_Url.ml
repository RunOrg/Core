(* © 2013 RunOrg *)

open UrlClient.Common

let home,   def_home   = root             "dms/repos"
let create, def_create = child def_home   "dms/repo/create"
let see,    def_see    = child def_create "dms/repo/view"
let file,   def_file   = child def_see    "dms/file"

let () = VNavbar.registerPlugin `DMS home `DMS_Navbar
