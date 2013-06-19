| `Inbox_Discussion -> "Conversation"

| `Inbox_New_Discussion -> "Conversation"
| `Inbox_New_Event -> "Activité"
| `Inbox_New -> "Créer :"

| `Inbox_Title -> "Messages et conversations"

| `Inbox_Empty -> "Aucune conversation à afficher"

| `Inbox_Filter f -> begin match f with 
    | `All -> "Toutes les conversations"
    | `Events -> "Activités"
    | `Groups -> "Groupes"
    | `HasFiles -> "Avec pièces jointes"
    | `HasPics -> "Avec photos"
    | `Private -> "Messages privés"
end 

| `Inbox_IsAdmin g -> 
  !! "En tant qu'%s, vous pouvez voir tous les messages de cet espace." 
    (macho "administrateur" "administratrice" g)
| `Inbox_IsAdmin_More -> "En savoir plus..."

