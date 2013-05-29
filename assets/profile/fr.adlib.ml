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
| `Profile_Forms_Edit   -> "Modification d'une Fiche"
| `Profile_Forms_Empty  -> "Aucune fiche disponible"

| `Profile_Form_Hidden -> "Secret"
| `Profile_Form_Create_Question -> "Quel type de fiche souhaitez-vous créer ?"
| `Profile_Form_Edit_Comment -> "Commentaire"
| `Profile_Form_Edit_Title -> "Titre"
| `Profile_Form_Edit_Required -> "Champ obligatoire"
| `Profile_Form_Edit_Hidden -> "Visibilité"
| `Profile_Form_Edit_Hidden_Label hidden -> 
  if hidden then "Seuls les responsables peuvent accéder à cette fiche"
  else "La personne concernée peut voir cette fiche"
| `Profile_Form_Edit_Save -> "Enregistrer"
| `Profile_Form_Edit -> "Modifier"
| `Profile_Form_Back -> "Retour"

| `Profile_Admin -> "Modifier"

| `Profile_Viewers_Title -> "Parents"
| `Profile_Viewers_Link -> "Parents et responsables légaux"
| `Profile_Viewers_Sub -> "Les parents peuvent voir les profils de leurs enfants"

| `Profile_ViewPick_Title -> "Ajouter"

| `Profile_Admin_Title -> "Administration"

| `Profile_Viewers_Label lbl -> begin match lbl with 
  | `Submit -> "Ajouter Parents"
  | `Help -> "Les parents peuvent voir et modifier le profil de leurs enfants. La liste ci-dessous recense les parents de ce profil :"
end
