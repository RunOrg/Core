| `Inbox_Discussion -> "Conversation"

| `Inbox_New_Discussion -> "Nouveau Message"
| `Inbox_New_Event -> "Nouvelle Activité"

| `Inbox_Title -> "Messages et conversations"

| `Inbox_Empty -> "Aucun message à afficher"

| `Inbox_Filter f -> begin match f with 
    | `All -> "Tous les messages"
    | `Events -> "Evènements"
    | `Groups -> "Groupes"
    | `HasFiles -> "Avec pièces jointes"
    | `HasPics -> "Avec photos"
end 

| `Inbox_IsAdmin g -> 
  !! "En tant qu'%s, vous pouvez voir tous les messages de cet espace." 
    (macho "administrateur" "administratrice" g)
| `Inbox_IsAdmin_More -> "En savoir plus..."
