| `Profile_NoEmail -> "Pas d'adresse e-mail"
| `Profile_Menu seg -> begin match seg with
    | `Files -> "Fichiers"
    | `Forms -> "Fiches"
    | `Groups -> "Groupes"
    | `Images -> "Photos"
    | `Messages -> "Messages"
end
