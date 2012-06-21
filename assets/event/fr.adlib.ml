| `Events_Link_New -> "Organiser une activité"
| `Events_Link_Options -> "Options"

| `Events_List_Empty -> "Aucune activité disponible"

| `Events_Help_Title -> "Visibilité"
| `Events_Help_Default -> "Par défaut, tous les membres de l'association peuvent voir les activités et demander à s'y inscrire." 
| `Events_Help_Website -> "Cette activité est visible depuis le site web de votre association, n'importe qui peut demander de s'y inscrire."
| `Events_Help_Secret -> "Cette activité est visible uniquement par ceux qui y sont inscrits ou invités. Personne ne peut s'y inscrire sans y être invité." 
| `Events_Help_Draft -> "Cette activité est en cours de préparation, elle n'est visible que par les responsables. Personne ne peut s'y inscrire pour l'instant."

| `Events_CountComing n -> Printf.sprintf "%d %s" n (if n = 1 then "inscrit" else "inscrits") 

| `Events_NoDate -> "Pas de date"
