| `Status_Secret -> "Secret"
| `Status_Website -> "Site Web"
| `Status_Draft  -> "Brouillon"
| `Status_Member _ -> "Membre"
| `Status_Admin g -> macho "Administrateur" "Administratrice" g
| `Status_Visitor g -> macho "Visiteur" "Visiteuse" g
| `Status_GroupMember g -> macho "Inscrit" "Inscrite" g
| `Status_Unpaid      g -> "Non Payé"
| `Status_Declined    g -> "Invitation Refusée"
| `Status_Invited     g -> macho "Invité" "Invitée" g
| `Status_Pending     g -> "À Valider"
