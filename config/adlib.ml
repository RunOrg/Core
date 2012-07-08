(* © 2012 RunOrg *)
open Common

module EntityName = struct

  let admin   = adlib "EntityAdminName" ~old:"entity.admin.name" "Administrateurs RunOrg"
  let members = adlib "EntityMembersName" "Tous les membres"

end
