| `Notify_List_Empty -> "Aucune notification récente"

| `Notify what -> begin
  match what with 
    | `NewInstance1 -> "a crée cette nouvelle association."
    | `NewUser1 -> "a crée ou confirmé son compte RunOrg."
    | `NewJoin1 -> "a adhéré ou a été inscrit à cette association."
    | `BecomeAdmin1 g -> "vous a nommé " ^ (macho "administrateur" "administratrice" g) ^ " de cet espace."
    | `BecomeMember1 -> "vous a accordé un accès à l'espace membres."
    | `Whatever -> "a fait quelque chose, mais nous ne savons pas quoi."
end
