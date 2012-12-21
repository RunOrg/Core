| `Delegate_Help kind -> begin match kind with 
    | `Event -> "Les organisateurs disposent de tous les pouvoirs sur cette activité."
    | `Group -> "Les responsables disposent de tous les pouvoirs sur ce groupe et son forum."
    | `Forum -> "Les modérateurs disposent de tous les pouvoirs sur ce forum."
    | `ProfileView -> "Les parents peuvent voir et modifier le profil de leurs enfants."
end

| `Delegate_Help_List kind -> begin match kind with 
    | `Event -> "La liste ci-dessous recense les organisateurs actuels :"
    | `Group -> "La liste ci-dessous recense les responsables actuels :"
    | `Forum -> "La liste ci-dessous recense les modérateurs actuels :"
    | `ProfileView -> "La liste ci-dessous recense les parents de ce profil :"
end

| `Delegate_Admins -> "Groupe"
| `Delegate_Add -> "Ajouter..."
| `Delegate_Add_Denied -> "Vous ne pouvez pas nommer de responsables sur ce groupe."
| `Delegate_Remove -> "Supprimer"

| `Delegate_Submit kind -> begin match kind with 
    | `Event -> "Nommer organisateurs"
    | `Group -> "Nommer responsables"
    | `Forum -> "Nommer modérateurs"
    | `ProfileView -> "Ajouter Parents"
end
