| `Groups_Create_Link -> "Créer un groupe..."
| `Groups_IsMember -> "Groupes dont je suis membre"
| `Groups_IsNotMember -> "Autres Groupes"

| `Group_NotFound -> "Vous n'êtes pas autorisé à voir les membres de ce groupe."

| `Group_Action_Admin -> "Administration"
| `Group_Action_Send -> "Envoyer un message"
| `Group_Action_Invite -> "Ajouter des membres"

| `Group_Admin_Title -> "Administration"

| `Group_Edit_Title -> "Modifier"
| `Group_Edit_Link -> "Options du groupe"
| `Group_Edit_Sub -> "Changez le nom et la visibilité de ce groupe"

| `Group_People_Title -> "Membres"
| `Group_People_Link -> "Gestion des membres"
| `Group_People_Sub -> "Inscrivez des membres et validez les demandes d'inscription"

| `Group_Invite_Title -> "Inscription"

| `Group_Forbidden_Title -> "Page inaccessible"
| `Group_Forbidden_Problem -> "Vous ne pouvez pas afficher cette page parce qu'elle a été supprimée ou que vous ne disposez pas des droits suffisants."
| `Group_Forbidden_Solution -> "Vous pouvez demander à un administrateur de vous confier ces droits."

| `Group_Missing -> "Le contenu de ce groupe n'est pas disponible actuellement en raison d'un problème technique."
| `Group_Missing_Link -> "Retour au groupe"

| `Groups_Create_Title -> "Créer un nouveau groupe"
| `Groups_Create_Step_One -> "Choisissez le type de groupe"
| `Groups_Create_Step_Two -> "Complétez ces informations"
| `Groups_Create_Field_Name -> "Le nom de votre groupe"
| `Groups_Create_Submit -> "Créer"
| `Groups_Create_Cancel -> "Annuler"

| `Group_Edit_Publish_Label what -> begin match what with
    | `Public -> "Visible depuis internet"
    | `Normal -> "Visible par tous les membres de l'association"
    | `Private -> "Sur invitation uniquement"
end
