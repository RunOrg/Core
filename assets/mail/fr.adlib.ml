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

| `Mail_Notify_BecomeMember_Title asso -> !! "Rejoignez l'espace membres de %s" asso
| `Mail_Notify_BecomeMember_Intro name -> !! "Bonjour %s" name
| `Mail_Notify_BecomeMember_Explanation (who,asso) -> 
  !! "%s vous invite à rejoindre l'espace membres de %s. Vous pourrez y trouver les dernières activités, photos ou annonces, et échanger avec les responsables et les autres membres. Pour vous connecter, cliquez sur le lien ci-dessous :" who asso
| `Mail_Notify_BecomeMember_Thanks asso -> !! "À bientôt sur %s" asso 

