| `Mail_Foot_SentBy -> "Envoyé par"
| `Mail_Foot_Via -> "via"
| `Mail_Foot_Unsubscribe -> "Ne plus rien recevoir"

| `Mail_SignupConfirm_Title -> "Confirmez votre inscription !"
| `Mail_SignupConfirm_Intro name -> !! "Bonjour %s," name
| `Mail_SignupConfirm_Welcome -> 
  "Afin de pouvoir profiter pleinement de votre inscription, vous devez confirmer que vous êtes bien propriétaire de ce compte."
| `Mail_SignupConfirm_Action email -> 
  !! "Pour confirmer votre compte %s, cliquez sur le lien ci-dessous :" email
| `Mail_SignupConfirm_Thanks -> 
  "Merci, et à très bientôt !"

| `Mail_PassReset_Title -> "Changer votre mot de passe"
| `Mail_PassReset_Intro name -> !! "Bonjour %s," name
| `Mail_PassReset_Explanation email -> 
  !! "Vous pouvez vous connecter directement à votre compte %s en cliquant sur le lien ci-dessous :" email 
| `Mail_PassReset_Thanks -> "Une fois connecté, vous pourrez changer votre mot de passe."

| `Mail_Unsubscribe_Title -> "Confirmez la suppression de votre compte"
| `Mail_Unsubscribe_Intro name -> !! "Bonjour %s," name
| `Mail_Unsubscribe_Explanation email ->
  !! "Vous avez demandé aujourd'hui la suppression définitive de votre compte %s sur notre plate-forme. Pour confirmer cette suppression, cliquez sur le lien ci-dessous. Cela supprimera votre compte et les données personnelles qui y sont associées, et empêchera nos clients de vous envoyer d'autres courriers." email
| `Mail_Unsubscribe_Warning -> "Attention : cliquer sur ce lien provoque la suppression immédiate et irréversible de votre compte."
| `Mail_Unsubscribe_Thanks -> "Si vous supprimez votre compte, alors ceci sera le dernier message que vous recevrez de RunOrg. Nous sommes tristes que votre expérience de nos services n'ait pas été aussi agréable que nous l'avons espéré, et nous nous excusons pour tout désagrément que vous avez pu subir."

| `Mail_Notify_BecomeMember_Title asso -> !! "Invitation - %s" asso
| `Mail_Notify_BecomeMember_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_BecomeMember_Explanation (who,asso) -> 
  !! "%s vous invite à rejoindre l'espace privé et sécurisé utilisé pour la communication au sein de %s." who asso
| `Mail_Notify_BecomeMember_Explanation2 asso -> 
  !! "%s utilise l'outil en ligne RunOrg pour la gestion de ses membres, activités et évènements." asso
| `Mail_Notify_BecomeMember_Explanation3 -> 
  "Pour répondre aux messages, visualiser les photos, participer aux évènements et aux sondages : créez votre compte en cliquant sur le lien ci-dessous :"
| `Mail_Notify_BecomeMember_Thanks asso -> !! "À bientôt sur %s" asso 

| `Mail_Notify_BecomeAdmin_Title asso -> !! "Droits d'administration - %s" asso
| `Mail_Notify_BecomeAdmin_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_BecomeAdmin_Explanation (who,asso) -> 
  !! "%s vous a transmis les pleins pouvoir d'administrateur de %s." who asso
| `Mail_Notify_BecomeAdmin_Explanation2 asso -> 
  !! "%s utilise l'outil en ligne RunOrg pour la gestion de ses membres, activités et évènements." asso
| `Mail_Notify_BecomeAdmin_Explanation3 -> 
  "Pour découvrir les fonctionnalités et les pouvoirs réservés aux administrateurs (création de groupes et d'activités, visibilité totale et modération) : cliquez sur le lien ci-dessous :"
| `Mail_Notify_BecomeAdmin_Responsability asso -> !! "Vous avez désormais une grande responsabilité dans l'annimation en ligne de %s ! Faites-en bon usage !" asso 
| `Mail_Notify_BecomeAdmin_Thanks asso -> !! "À bientôt sur %s" asso 

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

| `Mail_Notify_InviteEvent_Title (who,what) -> !! "%s vous invite : %s" who what
| `Mail_Notify_InviteEvent_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_InviteEvent_Explanation (who,what,asso) -> 
  !! "Vous êtes invité par %s à l'évènement %s organisé par %s." who what asso
| `Mail_Notify_InviteEvent_Explanation2 who -> 
  !! "%s vous remercie de répondre à cette invitation en utilisant le lien ci-dessous :" who
| `Mail_Notify_InviteEvent_Thanks asso -> !! "À bientôt sur %s" asso

| `Mail_Notify_JoinPending_Title (who,what) -> !! "%s demande à rejoindre %s" who what
| `Mail_Notify_JoinPending_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_JoinPending_Explanation (who,what,asso) -> 
  !! "La demande de %s à rejoindre %s est en attente dans %s." who what asso
| `Mail_Notify_JoinPending_Explanation2 -> 
   "En tant qu'administrateur vous pouvez visualiser et traiter cette demande en suivant le lien ci-dessous :"
| `Mail_Notify_JoinPending_Thanks asso -> !! "À bientôt sur %s" asso


