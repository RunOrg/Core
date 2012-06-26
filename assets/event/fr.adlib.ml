| `Events_Link_New -> "Organiser une activité"
| `Events_Link_Options -> "Paramètres"

| `Events_List_Empty -> "Aucune activité disponible"

| `Events_Title -> "Activités"

| `Events_Help_Title -> "Visibilité"
| `Events_Help_Default -> "Par défaut, tous les membres de l'association peuvent voir les activités et demander à s'y inscrire." 
| `Events_Help_Website -> "Cette activité est visible depuis le site web de votre association, n'importe qui peut demander de s'y inscrire."
| `Events_Help_Secret -> "Cette activité est visible uniquement par ceux qui y sont inscrits ou invités. Personne ne peut s'y inscrire sans y être invité." 
| `Events_Help_Draft -> "Cette activité est en cours de préparation, elle n'est visible que par les responsables. Personne ne peut s'y inscrire pour l'instant."

| `Events_CountComing n -> Printf.sprintf "%d %s" n (if n = 1 then "inscrit" else "inscrits") 

| `Events_NoDate -> "Pas de date"

| `Events_Options_Title -> "Paramètres"
| `Events_Options_CanCreate -> "Qui peut organiser des activités ?"
| `Events_Options_CanCreate_Detail -> "Seuls les administrateurs peuvent publier des activités sur le site web ou modifier des activités créées par les autres."
| `Events_Options_Admin -> "Uniquement les administrateurs"
| `Events_Options_Member -> "Tout le monde"
| `Events_Options_Submit -> "Enregistrer"

| `Events_Create_Title -> "Organiser une nouvelle activité"
| `Events_Create_Step_One -> "Choisissez le type d'activité"
| `Events_Create_Step_Two -> "Complétez ces informations"
| `Events_Create_Field_Name -> "Le nom de votre activité"
| `Events_Create_Field_Picture -> "Le logo ou la photo de l'activité" 
| `Events_Create_Edit_Picture -> "Modifier"
| `Events_Create_Submit -> "Continuer"
| `Events_Create_Cancel -> "Annuler"

| `Events_CreateForbidden_Title -> "Organiser une nouvelle activité"
| `Events_CreateForbidden_Problem -> "Les responsables de cet espace ont choisi d'interdire l'organisation de nouvelles activités par des non-administrateurs. Vous ne disposez pas des droits nécessaires pour organiser une activité."
| `Events_CreateForbidden_Solution -> "Vous pouvez demander à un administrateur de vous confier ces droits, ou de créer une nouvelle activité à votre place et de vous en nommer responsable."
| `Events_CreateForbidden_Back -> "Retour"

| `Event_Section_Wall -> "Discussions"
| `Event_Section_People -> "Inscrits"
| `Event_Section_Album -> "Photos"
| `Event_Section_Folder -> "Fichiers"
| `Event_Section_Chat -> "Chat"
| `Event_Section_Votes -> "Votes"

| `Event_Pic_Change -> "Changer l'image"
| `Event_Admin -> "Administration"
| `Event_Invite -> "Inviter des participants"

| `Event_Desc_Empty -> "Pas de description"
| `Event_When -> "Quand ?"
| `Event_Where -> "Où ?"
| `Event_More_Details -> "Plus de Détails"
