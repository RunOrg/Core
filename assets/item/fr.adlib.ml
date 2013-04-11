| `Item_Author_Action what -> begin match what with 
    | `Message -> "Message"
    | `MiniPoll -> "Sondage"
    | `Mail -> "Email"
end 

| `Item_Remove -> "Supprimer"

| `Item_Comments_More -> "Voir les commentaires précédents"

| `Item_Notify_Title subject -> subject
| `Item_Notify_Body asso -> !! "Ce message a été publié dans «%s»" asso
| `Item_Notify_Body2 -> "Pour y répondre, ou pour consulter les réponses déjà écrites, cliquez sur le bouton ci-dessous."
| `Item_Notify_Button -> "Plus de détails"
