| `Comment_Remove -> "Supprimer"
| `Comment_Action -> "a répondu :"
| `Comment_Post_Label -> "Laissez un commentaire ..."
| `Comment_Post_Submit -> "Répondre"

| `Comment_Notify_Title context -> "Re: " ^ context
| `Comment_Notify_Action -> ""
| `Comment_Notify_Body asso -> 
  !! "Cette réponse a été laissée sur un message publié dans %s." asso 
| `Comment_Notify_Body2 -> "Pour consulter toutes les réponses, et y répondre vous-même, cliquez sur le lien ci-dessous."
| `Comment_Notify_Button -> "Voir détails"

