| `Item_Author_Action what -> begin match what with 
    | `Message -> "a écrit :"
end 

| `Item_Reply -> "Répondre"
| `Item_Remove -> "Supprimer"
| `Item_Hide -> "Cacher"

| `Item_Comments_More -> "Commentaires précédents"
