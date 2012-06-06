| `Website_Title website -> website
| `Website_Article_Title (website,article) -> article ^ " - " ^ website
| `Website_MiniCalendar_Go -> "Aller à l'agenda"

| `Website_Calendar_Title website -> "Agenda - " ^ website

| `Website_Event_Title (website,event) -> event ^ " - " ^ website

| `Website_Count_Subscribers i -> if i = 1 then "Abonné" else "Abonnés"
| `Website_Count_Articles i -> if i = 1 then "Article" else "Articles"
| `Website_Subscribe_Call -> "Abonnez-vous et recevez par e-mail les nouveaux articles publiés sur ce blog !"
| `Website_Subscribe_Button -> "Abonnement"
| `Website_Subscribe_Email -> "Votre e-mail"
| `Website_Subscribe_Required -> "Champ obligatoire"
| `Website_Subscribe_BadEmail -> "Cet e-mail semble être incorrect"
| `Website_Unsubscribe_Call -> "Vous recevez par e-mail tous les nouveaux articles publiés sur ce blog."
| `Website_Unsubscribe_Button -> "Se désabonner"
