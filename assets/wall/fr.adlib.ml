| `Feed_Post_Message  -> "Message"
| `Feed_Post_Picture  -> "Picture"
| `Feed_Post_File     -> "Fichier"
| `Feed_Post_MiniPoll -> "Sondage"
| `Feed_Post_Mail     -> "Email"

| `Feed_Post_Message_Label -> "Écrire un nouveau message..."
| `Feed_Post_MiniPoll_Label -> "Le sujet de votre sondage..."
| `Feed_Post_MiniPoll_Multiple -> "Question à choix multiples"
| `Feed_Post_MiniPoll_Yes -> "Ecrivez ici votre choix 1"
| `Feed_Post_MiniPoll_No  -> "Choix 2..."

| `Feed_Post_Mail_To -> "Destinataires"
| `Feed_Post_Mail_Subject -> "Objet"
| `Feed_Post_Mail_OnlyAdmin -> "Seuls les responsables peuvent envoyer des emails."

| `Feed_Post_Submit -> "Envoyer"

| `Feed_Is_ReadOnly -> "Vous n'êtes pas autorisé à publier de messages ici"

| `Feed_RW_Empty -> "Aucune discussion disponible"
| `Feed_RO_Empty -> "Aucune discussion disponible"
| `Feed_None -> "Aucune discussion disponible"

| `Feed_Mail_SentTo who -> begin match who with 
    | `Everyone -> "Tous les membres de cette association" 
    | `Group -> "Tous les membres de ce groupe"
    | `Forum -> "Tous les participants à ce forum"
    | `Event -> "Tous les inscrits et invités à cette activité"
end 
