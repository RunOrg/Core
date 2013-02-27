(* © 2013 RunOrg *)

open UrlClient.Common

let upform, def_upform = O.declare O.client "dms/upload/form" (A.rr IFile.arg A.string) 

let home,   def_home   = root             "dms/repos"
let create, def_create = child def_home   "dms/repo/create"
let see,    def_see    = child def_create "dms/repo/view"
let upload, def_upload = child def_see    "dms/upload"
let file,   def_file   = child def_upload "dms/doc"

let () = VNavbar.registerPlugin `DMS home `DMS_Navbar
