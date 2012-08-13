| `Profile_NoEmail -> "Pas d'adresse e-mail"
| `Profile_Menu seg -> begin match seg with
    | `Files -> "Fichiers"
    | `Forms -> "Fiches"
    | `Groups -> "Groupes"
    | `Images -> "Photos"
    | `Messages -> "Messages"
end
| `Profile_NoGroups -> "Ce profil n'est inscrit dans aucun groupe"

| `Profile_Forms_Create -> "Nouvelle Fiche"
| `Profile_Forms_Empty  -> "Aucune fiche disponible"
