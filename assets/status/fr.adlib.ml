| `Status_Private -> "Privé"
| `Status_Website -> "Site Web"
| `Status_Draft  -> "Brouillon"
| `Status_Member _ -> "Membre"
| `Status_Admin g -> macho "Administrateur" "Administratrice" g
| `Status_Visitor g -> macho "Visiteur" "Visiteuse" g
