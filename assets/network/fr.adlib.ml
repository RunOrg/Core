| `Network_List_All -> "Annuaire des associations"
| `Network_List_Filter -> "Filtrer par étiquette"
| `Network_List_Empty -> "Aucune association trouvée"
| `Network_Title -> "Le Réseau des Associations - RunOrg"
| `Network_Search -> "Chercher"

| `Network_Missing -> "Votre association n'apparaît pas dans la liste ?"
| `Network_Missing_Create -> "Créez gratuitement son espace privé"

| `Network_News_Title -> "Actualités - Le Réseau des Associations - RunOrg"
| `Network_News_Explain -> "Cette page recense les actualités des associations du réseau RunOrg. Vous pouvez vous abonner individuellement aux associations dont les actualités vous intéressent."

| `Network_Unbound -> "Installation en cours"
| `Network_Unbound_Welcome -> "Bienvenue !"
| `Network_Unbound_Soon -> "À cette adresse, vous trouverez bientôt :"
| `Network_Unbound_Teaser_Public -> "Un site web public avec des actualités, un agenda et la possibilité d'adhérer en ligne."
| `Network_Unbound_Teaser_Private -> "Un espace membres privé avec forums de discussions, albums photo, agenda privé et partage de documents."
| `Network_Unbound_Installing -> "L'installation de cet espace n'est pas encore achevée."
| `Network_Unbound_Finish -> "Vous êtes responsable de cet espace ?"
| `Network_Unbound_Finish_Submit -> "Finir l'installation"

| `Network_Install_Intro -> "Pour finir l'installation, nous venons de vous envoyer un email."
| `Network_Install_NextSteps -> "Il décrit les prochaines étapes pour la mise en place de votre espace dédié."
| `Network_Install_Soon -> "À tout de suite sur votre nouvel outil de gestion en ligne !" 
| `Network_Install_SentTo owid -> "L'email a été envoyé aux adresses électroniques des responsables telles qu'elles ont été déclarées auprès " ^ (ConfigWhite.of_the owid) ^ "."
| `Network_Install_Contact owid -> "En cas de problèmes ou pour plus d'informations, contactez directement " ^ (ConfigWhite.the owid) ^ " :"  

| `Network_ConfirmOwner_Intro -> "Pour finir l'installation, nous venons de vous envoyer un email."
| `Network_ConfirmOwner_NextSteps -> "Il décrit les prochaines étapes pour la mise en place de votre espace dédié."
| `Network_ConfirmOwner_Soon -> "À tout de suite sur votre nouvel outil de gestion en ligne !" 

| `Network_Install_Field_Name -> "Le nom de votre espace"
| `Network_Install_Field_Key -> "L'adresse web pour y accéder"
| `Network_Install_Add_Picture -> "Ajouter un logo ou une photo..."
| `Network_Install_Field_Picture -> "Le logo ou la photo de l'espace" 
| `Network_Install_Edit_Picture -> "Modifier"
| `Network_Install_Add_Description -> "Ajouter une description..."
| `Network_Install_Field_Description -> "Une courte description"
| `Network_Install_Submit -> "Confirmer ces informations"

| `Network_Notify_CanInstall_Title asso -> !! "Installation - %s" asso
| `Network_Notify_CanInstall_Intro -> "Bonjour,"
| `Network_Notify_CanInstall_Explanation asso -> 
  !! "Vous (ou un autre responsable) avez demandé à finir l'installation de l'espace privé en ligne pour %s. Il ne vous reste plus qu'à vérifier l'exactitude des données de cet espace. Pour cela, cliquez sur le bouton ci-dessous et suivez les instructions." asso
| `Network_Notify_CanInstall_Button -> "Continuer"
