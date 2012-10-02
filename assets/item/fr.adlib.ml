| `Item_Author_Action what -> begin match what with 
    | `Message -> "a écrit :"
    | `MiniPoll -> "a organisé un sondage :"
    | `Mail -> "a envoyé un email :"
end 

| `Item_Remove -> "Supprimer"

| `Item_Comments_More -> "Commentaires précédents"
