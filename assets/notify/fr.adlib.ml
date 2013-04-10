| `Notify_List_Empty -> "Aucune notification récente"

| `Notify_Follow_ConfirmFirst -> "Confirmation nécessaire"

| `Notify_Expired_Title -> "Ce lien a expiré !" 
| `Notify_Expired_Body -> "Pour des raisons de sécurité, le lien que vous avez suivi a dépassé sa date limite d'utilisation. Nous vous avons envoyé un nouveau lien par mail."

| `Notify_Link_Settings -> "Paramètres"
| `Notify_Link_Zap -> "Tout marquer comme lu"

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
