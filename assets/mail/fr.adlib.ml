| `Mail_Foot_SentBy -> "Envoyé par"
| `Mail_Foot_Via -> "via"
| `Mail_Foot_Unsubscribe -> "Ne plus rien recevoir"

| `Mail_PassReset_Title -> "Changer votre mot de passe"
| `Mail_PassReset_Intro name -> !! "Bonjour %s," name
| `Mail_PassReset_Explanation email -> 
  !! "Vous pouvez vous connecter directement à votre compte %s en cliquant sur le lien ci-dessous. Une fois connecté, vous pourrez changer votre mot de passe." email 
| `Mail_PassReset_Button -> "Connexion"

(* I18N below have not been used in the new system *)

| `Mail_SignupConfirm_Title -> "Confirmez votre inscription !"
| `Mail_SignupConfirm_Intro name -> !! "Bonjour %s," name
| `Mail_SignupConfirm_Welcome -> 
  "Afin de pouvoir profiter pleinement de votre inscription, vous devez confirmer que vous êtes bien propriétaire de ce compte."
| `Mail_SignupConfirm_Action email -> 
  !! "Pour confirmer votre compte %s, cliquez sur le lien ci-dessous :" email
| `Mail_SignupConfirm_Thanks -> 
  "Merci, et à très bientôt !"


| `Mail_Unsubscribe_Title -> "Confirmez la suppression de votre compte"
| `Mail_Unsubscribe_Intro name -> !! "Bonjour %s," name
| `Mail_Unsubscribe_Explanation email ->
  !! "Vous avez demandé aujourd'hui la suppression définitive de votre compte %s sur notre plate-forme. Pour confirmer cette suppression, cliquez sur le lien ci-dessous. Cela supprimera votre compte et les données personnelles qui y sont associées, et empêchera nos clients de vous envoyer d'autres courriers." email
| `Mail_Unsubscribe_Warning -> "Attention : cliquer sur ce lien provoque la suppression immédiate et irréversible de votre compte."
| `Mail_Unsubscribe_Thanks -> "Si vous supprimez votre compte, alors ceci sera le dernier message que vous recevrez de RunOrg. Nous sommes tristes que votre expérience de nos services n'ait pas été aussi agréable que nous l'avons espéré, et nous nous excusons pour tout désagrément que vous avez pu subir."

| `Mail_Notify_PublishItem_Title who -> !! "Nouveau message de %s" who
| `Mail_Notify_PublishItem_Explanation (who,asso) -> 
  !! "Ce message a été écrit par %s sur %s." who asso
| `Mail_Notify_PublishItem_Explanation2 -> 
  "Vous pouvez y répondre en cliquant sur le lien ci-dessous :"
| `Mail_Notify_PublishItem_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_Notify_LikeYourItem_Title who -> !! "%s suit votre message" who
| `Mail_Notify_LikeYourItem_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_LikeYourItem_Explanation (who,asso) -> 
  !! "%s suit désormais l'un de vos message sur %s. Vous pouvez visualiser ce message à l'aide du lien ci dessous :" who asso
| `Mail_Notify_LikeYourItem_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_Notify_CommentYourItem_Title who -> !! "Réponse de %s" who
| `Mail_Notify_CommentYourItem_Explanation (who,asso) -> 
  !! "%s a répondu à votre message sur %s. Vous pouvez lui répondre en cliquant sur le lien ci-dessous :" who asso
| `Mail_Notify_CommentYourItem_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_Notify_CommentItem_Title who -> !! "Réponse de %s" who
| `Mail_Notify_CommentItem_Explanation (who,asso) -> 
  !! "%s a répondu dans une conversation que vous suivez sur %s. Vous pouvez lui répondre en cliquant sur le lien ci-dessous :" who asso
| `Mail_Notify_CommentItem_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_Notify_EventInvite_Title (who,what) -> !! "%s vous invite : %s" who what
| `Mail_Notify_EventInvite_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_EventInvite_Explanation (who,what,asso) -> 
  !! "Vous êtes invité par %s à l'évènement %s organisé par %s." who what asso
| `Mail_Notify_EventInvite_Explanation2 who -> 
  !! "%s vous remercie de répondre à cette invitation en utilisant le lien ci-dessous :" who
| `Mail_Notify_EventInvite_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_Notify_EventRequest_Title (who,what) -> !! "%s demande à participer à %s" who what
| `Mail_Notify_EventRequest_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_EventRequest_Explanation (who,what,asso) -> 
  !! "La demande de %s à rejoindre %s est en attente dans %s." who what asso
| `Mail_Notify_EventRequest_Explanation2 -> 
   "En tant qu'administrateur vous pouvez visualiser et traiter cette demande en suivant le lien ci-dessous :"
| `Mail_Notify_EventRequest_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_Notify_GroupRequest_Title (who,what) -> !! "%s demande à rejoindre %s" who what
| `Mail_Notify_GroupRequest_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_GroupRequest_Explanation (who,what,asso) -> 
  !! "La demande de %s à rejoindre %s est en attente dans %s." who what asso
| `Mail_Notify_GroupRequest_Explanation2 -> 
   "En tant qu'administrateur vous pouvez visualiser et traiter cette demande en suivant le lien ci-dessous :"
| `Mail_Notify_GroupRequest_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_NotifyResend_Title -> "Nouveau lien de connexion"
| `Mail_NotifyResend_Intro name -> !! "Bonjour %s" name
| `Mail_NotifyResend_Explain -> "Vous avez visité un lien expiré, voici un nouveau lien à jour :"
| `Mail_NotifyResend_Thanks -> "À bientôt !"

| `Mail_Notify_Welcome_Title -> "Bienvenue sur RunOrg !"
| `Mail_Notify_Welcome_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_Welcome_Explanation_WithPassword -> "Vous venez de créer un compte sur notre plateforme et nous vous en remercions ! RunOrg vous permet de personnaliser votre profil et les informations que vous partagez avec vos organisations. Pour en savoir plus, cliquez sur le lien ci-dessous :"
| `Mail_Notify_Welcome_Explanation_WithoutPassword -> 
   "Vous venez de vous connecter pour la première fois sur notre plateforme et nous vous en remercions ! Pour vous y connecter à l'avenir et pour protéger votre vie privée : un mot de passe vous sera demandé. Pour le saisir, cliquez sur lien ci-dessous :"

| `Mail_Notify_Welcome_Thanks -> "Bien cordialement, L'équipe RunOrg"

| `Mail_Notify_CanInstall_Title asso -> !! "Installation - %s" asso
| `Mail_Notify_CanInstall_Intro -> "Bonjour,"
| `Mail_Notify_CanInstall_Explanation asso -> 
  !! "Vous (ou un autre responsable) avez demandé à finir l'installation de l'espace privé en ligne pour %s." asso
| `Mail_Notify_CanInstall_Explanation2 -> "Il ne vous reste plus qu'à vérifier l'exactitude des données de cet espace. Pour cela, cliquez sur le lien ci-dessus et suivez les instructions :"
| `Mail_Notify_CanInstall_Thanks asso -> !! "À bientôt sur %s" asso









