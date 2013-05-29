(* © 2013 RunOrg *)

open UrlClient.Common

let upform, def_upform = O.declare O.client "dms/upload/form" (A.rr IFile.arg A.string) 

let home,   def_home   = root             "dms/repos"
let create, def_create = child def_home   "dms/repo/create"
let see,    def_see    = child def_create "dms/repo/view"
let upload, def_upload = child def_see    "dms/upload"
let file,   def_file   = child def_upload "dms/doc/view"

module Doc = struct

  let version, def_version = child def_file  "dms/doc/add-version"
  let admin,   def_admin   = child def_file  "dms/doc/admin"
  let edit,    def_edit    = child def_admin "dms/doc/edit"
  let share,   def_share   = child def_admin "dms/doc/share"
  let delete,  def_delete  = child def_admin "dms/doc/delete"
  let inrepo,  def_inrepo  = O.declare O.client "dms/doc/inrepo" (A.r DMS_IDocument.arg) 

end

module Task = struct

  let create,   def_create = child def_file   "dms/task/create"
  let edit,     def_edit   = child def_create "dms/task/edit"

end

module Repo = struct

  let admin,    def_admin    = child def_see      "dms/repo/admin"
  let upload,   def_upload   = child def_admin    "dms/repo/upload"
  let delete,   def_delete   = child def_admin    "dms/repo/delete"
  let edit,     def_edit     = child def_admin    "dms/repo/edit"
  let advanced, def_advanced = child def_admin    "dms/repo/advanced"
  let uploader, def_uploader = child def_admin    "dms/repo/uploader"
  let delpick,  def_delpick  = child def_uploader "dms/repo/delpick"
  let admins,   def_admins   = child def_admin    "dms/repo/admins"
  let admpick,  def_admpick  = child def_admins   "dms/repo/admpick"
  
end


let () = VNavbar.registerPlugin `DMS home `DMS_Navbar
