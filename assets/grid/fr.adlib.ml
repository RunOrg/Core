| `Grid_Block_Wait -> "Nous préparons l'affichage de cette liste."
| `Grid_Block_Wait_Thanks -> "Merci de votre patience"
| `Grid_Block_Empty -> "Aucun élément à afficher"
| `Grid_Link_Invite -> "Ajouter des membres"
| `Grid_Link_Columns -> "Modifier les colonnes"
| `Grid_Link_Export -> "Télécharger"

| `Grid_Column_Add -> "Ajouter"

| `Grid_Source_Profile -> "Depuis le profil membres"
| `Grid_Source_Local -> "Depuis cette liste"

| `Grid_Source_Profile_Short -> "Profil"
| `Grid_Source_Profile_Field f -> begin match f with  
    | `Fullname  -> "Nom complet"
    | `Firstname -> "Prénom"
    | `Lastname  -> "Nom"
    | `Email     -> "Email"
    | `Birthdate -> "Date de naissance"
    | `City      -> "Ville"
    | `Address   -> "Adresse"
    | `Zipcode   -> "Code postal"
    | `Country   -> "Pays"
    | `Phone     -> "Téléphone"
    | `Cellphone -> "Téléphone portable"
    | `Gender    -> "Sexe"
end

| `Grid_Source_Group_Unknown -> "Objet inconnu"

| `Grid_Source_Local_Field f -> begin match f with 
    | `Field f -> f
    | `Status  -> "Statut"
    | `Date    -> "Dernière modification"
end

| `Grid_Edit_Source -> "Source"
| `Grid_Edit_Name -> "Nom"
| `Grid_Edit_Save -> "Enregistrer"
| `Grid_Edit_Delete -> "Supprimer"
| `Grid_Edit_Locked -> "Cette colonne ne peut pas être modifée"
