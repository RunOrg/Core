| `Item_Author_Action what -> begin match what with 
    | `Message -> "Message"
    | `MiniPoll -> "Sondage"
    | `Mail -> "Email"
end 

| `Item_Remove -> "Supprimer"

| `Item_Comments_More -> "Voir les commentaires précédents"
