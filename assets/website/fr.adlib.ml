| `Website_Title website -> website
| `Website_Article_Title (website,article) -> article ^ " - " ^ website
| `Website_MiniCalendar_Go -> "Aller à l'agenda"

| `Website_Article_New -> "Publier un nouvel article"
| `Website_Article_Edit -> "Modifier cet article"

| `Website_Calendar_Title website -> "Agenda - " ^ website
| `Website_Calendar_List -> "Activités prévues"
| `Website_Calendar_Empty -> "Aucune activité n'est prévue."

| `Website_Event_Title (website,event) -> event ^ " - " ^ website
| `Website_Event_When -> "Quand ?"
| `Website_Event_Where -> "Où ?"

| `Website_About_Title website -> "À propos - " ^ website
| `Website_About_NoDesc -> "Cette association n'a pas renseigné de description."
| `Website_About_Site -> "Site Officiel"
| `Website_About_Twitter -> "Twitter"
| `Website_About_Facebook -> "Facebook"
| `Website_About_Edit -> "Modifier cette page"

| `Website_Count_Subscribers i -> if i = 1 then "Abonné" else "Abonnés"
| `Website_Count_Articles i -> if i = 1 then "Article" else "Articles"
| `Website_Subscribe_Call -> "Abonnez-vous et recevez par e-mail les nouveaux articles publiés sur ce blog !"
| `Website_Subscribe_Button -> "Abonnement"
| `Website_Subscribe_Email -> "Votre e-mail"
| `Website_Subscribe_Required -> "Champ obligatoire"
| `Website_Subscribe_BadEmail -> "Cet e-mail semble être incorrect"
| `Website_Unsubscribe_Call -> "Vous recevez par e-mail tous les nouveaux articles publiés sur ce blog."
| `Website_Unsubscribe_Button -> "Se désabonner"

| `Website_Admin_Article_Title -> "Titre de l'article"
| `Website_Admin_Article_Text  -> "Texte"
| `Website_Admin_Article_New   -> "Nouvel article"
| `Website_Admin_Article_Edit  -> "Modifier un article"
| `Website_Admin_Article_Submit -> "Publier"

| `Website_Admin_About_Edit -> "Modifier"
| `Website_Admin_About_Name -> "Nom"
| `Website_Admin_About_Description -> "Description"
| `Website_Admin_About_Tags -> "Mots-clés"
| `Website_Admin_About_Tags_Detail -> "Permettent aux internautes de vous trouver sur notre annuaire"
| `Website_Admin_About_Facebook -> "Adresse Facebook"
| `Website_Admin_About_Twitter -> "Adresse Twitter"
| `Website_Admin_About_Website -> "Site web officiel"
| `Website_Admin_About_Address -> "Adresse postale"
| `Website_Admin_About_Submit -> "Enregistrer"

| `Website_Admin_Picture_Edit -> "Logo" 

| `Website_Map_Enlarge -> "Agrandir la carte"
