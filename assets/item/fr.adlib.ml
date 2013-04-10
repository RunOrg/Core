| `Item_Author_Action what -> begin match what with 
    | `Message -> "Message"
    | `MiniPoll -> "Sondage"
    | `Mail -> "Email"
end 

| `Item_Remove -> "Supprimer"

| `Item_Comments_More -> "Voir les commentaires précédents"

| `Item_Notify_Title subject -> subject
| `Item_Notify_Body -> "Pour répondre à ce message, ou pour consulter les réponses déjà écrites, cliquez sur le bouton ci-dessous."
| `Item_Notify_Button -> "Plus de détails"
