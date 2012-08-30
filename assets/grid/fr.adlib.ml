| `Grid_Block_Wait -> "Nous préparons l'affichage de cette liste."
| `Grid_Block_Wait_Thanks -> "Merci de votre patience"
| `Grid_Block_Empty -> "Aucun élément à afficher"
| `Grid_Link_Invite -> "Ajouter des membres"

| `Grid_Columns_Add -> "Nouvelle Colonne"
| `Grid_Column_Add -> "Ajouter"

| `Grid_Source_Profile -> "Depuis le profil membres"
| `Grid_Source_Local -> "Depuis cette liste"

| `Grid_Source_Profile_Field f -> begin match f with  
    | `Birthdate -> "Date de naissance"
    | `City      -> "Ville"
    | `Address   -> "Adresse"
    | `Zipcode   -> "Code postal"
    | `Country   -> "Pays"
    | `Phone     -> "Téléphone"
    | `Cellphone -> "Téléphone portable"
    | `Gender    -> "Sexe"
end

| `Grid_Source_Local_Field f -> begin match f with 
    | `Field f -> f
    | `Status  -> "Statut"
    | `Date    -> "Dernière modification"
end
