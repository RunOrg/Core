| `Notify_List_Empty -> "Aucune notification récente"

| `Notify what -> begin
  match what with 
    | `NewInstance1 -> "a crée cette nouvelle association."
    | `NewUser1 -> "a crée ou confirmé son compte RunOrg."
    | `NewJoin1 -> "a adhéré ou a été inscrit à cette association."
    | `BecomeAdmin1 g -> "vous a nommé " ^ (macho "administrateur" "administratrice" g) ^ " de cet espace."
    | `BecomeMember1 -> "vous a accordé un accès à l'espace membres."
    | `NewFavorite1 -> "a ajouté un de vos messages à ses favoris."
    | `NewCommentSelf1 -> "a laissé un commentaire sur un de vos messages."
    | `NewCommentOther1 -> "a laissé un commentaire sur un message de "
    | `NewCommentOther2 -> "."
    | `NewWallItem1 -> "a publié un nouveau message."
    | `EntityInvite1 -> "vous invite à participer à «"
    | `EntityInvite2 -> "»"
    | `EntityRequest1 -> "a demandé son inscription à «"
    | `EntityRequest2 -> "»"
    | `CanInstall1 -> "Terminez l'installation de votre espace privé !"
    | `Whatever -> "a fait quelque chose, mais nous ne savons pas quoi."
end

| `Notify_Expired_Title -> "Ce lien a expiré !" 
| `Notify_Expired_Body -> "Pour des raisons de sécurité, le lien que vous avez suivi a dépassé sa date limite d'utilisation. Nous vous avons envoyé un nouveau lien par mail."

| `Notify_Link_Settings -> "Paramètres"

| `Notify_Title -> "Notifications"

| `Notify_Settings_Title -> "Paramètres"
| `Notify_Settings_Choice c -> begin 
  match c with 
    | `Default -> "Options par défaut"
    | `Everything -> "Recevoir toutes les notifications" 
    | `Relevant -> "Uniquement les notifications qui me concernent"
    | `Nothing -> "Ne rien recevoir"
end
| `Notify_Settings_Detail c -> begin
  match c with 
    | `Everything -> "Vous recevez en temps réel les notifications par mail"
    | `Relevant -> "Des résumes quotidiens ou hebdomadaires vous informent du reste"
    | `Nothing -> "Vous ne recevez strictement aucune notification"
end
| `Notify_Settings_Submit -> "Enregistrer"
| `Notify_Settings_Default -> "Options par défaut"
