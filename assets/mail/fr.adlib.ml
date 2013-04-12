| `Mail_Foot_SentBy -> "Envoyé par"
| `Mail_Foot_Via -> "via"
| `Mail_Foot_Unsubscribe -> "Ne plus rien recevoir"

| `Mail_PassReset_Title -> "Changer votre mot de passe"
| `Mail_PassReset_Intro name -> !! "Bonjour %s," name
| `Mail_PassReset_Explanation email -> 
  !! "Vous pouvez vous connecter directement à votre compte %s en cliquant sur le lien ci-dessous. Une fois connecté, vous pourrez changer votre mot de passe." email 
| `Mail_PassReset_Button -> "Connexion"

| `Mail_SignupConfirm_Title -> "Confirmez votre inscription !"
| `Mail_SignupConfirm_Intro name -> !! "Bonjour %s," name
| `Mail_SignupConfirm_Explanation email -> 
  !! "Afin de pouvoir profiter pleinement de votre inscription, vous devez confirmer que vous êtes bien propriétaire de ce compte %s. Pour cela, cliquez sur le bouton ci-dessous :" email
| `Mail_SignupConfirm_Button -> "Confirmer"

| `Mail_Unsubscribe_Title -> "Confirmez la suppression de votre compte"
| `Mail_Unsubscribe_Intro name -> !! "Bonjour %s," name
| `Mail_Unsubscribe_Explanation email ->
  !! "Vous avez demandé aujourd'hui la suppression définitive de votre compte %s sur notre plate-forme. Pour confirmer cette suppression, cliquez sur le lien ci-dessous. Cela supprimera votre compte et les données personnelles qui y sont associées, et empêchera nos clients de vous envoyer d'autres courriers." email
| `Mail_Unsubscribe_Warning -> "Attention : cliquer sur ce lien provoque la suppression immédiate et irréversible de votre compte."
| `Mail_Unsubscribe_Thanks -> "Si vous supprimez votre compte, alors ceci sera le dernier message que vous recevrez de RunOrg. Nous sommes tristes que votre expérience de nos services n'ait pas été aussi agréable que nous l'avons espéré, et nous nous excusons pour tout désagrément que vous avez pu subir."
| `Mail_Unsubscribe_Button -> "Supprimer définitivement mon compte"

| `Mail_Block_Title block -> 
  if block then "Inscription confirmée"
  else "Désinscription effectuée"

| `Mail_Block_Body block ->
  if block then "Vous ne recevrez plus aucun courriel de cette communauté."
  else "Bienvenue ! Vous recevrez maintenant tous les courriels envoyés par cette communauté."







