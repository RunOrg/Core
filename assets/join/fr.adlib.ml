| `Join_Edit_Event_Invite -> "Inviter"
| `Join_Edit_Event_Add    -> "Inscrire d'office"
| `Join_Edit_Add -> "Inscrire"
| `Join_Edit_Accept -> "Valider l'inscription"
| `Join_Edit_Decline -> "Refuser"
| `Join_Edit_Remove -> "Désinscrire"
| `Join_Edit_Event_Uninvite -> "Retirer l'invitation"

| `Join_Edit_Save -> "Enregistrer"

| `Join_Self_Event_Member g -> "Vous participez à cette activité."
| `Join_Self_Group_Member g -> "Vous êtes membre de ce groupe."
| `Join_Self_Forum_Member g -> "Vous avez accès à ce forum."
| `Join_Self_Event_NotMember g -> "Vous ne participez pas à cette activité."
| `Join_Self_Group_NotMember g -> "Vous n'êtes pas membre de ce groupe."
| `Join_Self_Forum_NotMember g -> "Vous ne participez pas à ce forum."
| `Join_Self_Event_Invited g -> !! "Vous êtes %s à cette activité." (macho "invité" "invitée" g) 
| `Join_Self_Pending g -> "Un responsable va valider votre inscription."

| `Join_Self_Cancel -> "Annuler"
| `Join_Self_Edit -> "Modifier..."
| `Join_Self_Join -> "Inscription"
| `Join_Self_JoinEdit -> "Inscription..."
| `Join_Self_Accept -> "Accepter"
| `Join_Self_AcceptEdit -> "Accepter..."
| `Join_Self_Decline -> "Refuser"

| `Join_Self_Save -> "Enregistrer"

| `Join_Public_Title inst -> "Accès membres - " ^ inst
| `Join_Public_Save -> "Inscription"
| `Join_Public_Description -> "Merci de remplir le formulaire d'inscription ci-dessous :"

| `Join_PublicNone_Title -> "Inscription en ligne"
| `Join_PublicNone_Problem -> "Les responsables de l'espace membre ont décidé d'interdire les demandes d'inscription par internet."
| `Join_PublicNone_Solution -> "Si vous pensez que vous devez avoir accès à cet espace, contactez un responsable."

| `Join_PublicPick_Description -> "Sélectionnez un type d'inscription ci-dessous :"
| `Join_PublicPick_Button -> "Inscription"

| `Join_PublicNoFields_Description -> "Souhaitez-vous confirmer votre demande d'inscription à cet espace membres ?"
| `Join_PublicNoFields_Submit -> "Confirmer mon inscription"

| `Join_PublicRequested_Description -> "Votre demande d'inscription doit maintenant être validée par un responsable. Vous recevrez un e-mail dès que ce sera le cas."     

| `Join_PublicConfirmed_Description -> "Votre demande d'inscription à cet espace a été acceptée."
| `Join_PublicConfirmed_Confirmed -> "Accéder à l'espace membres"
