| `Website_Title website -> website
| `Website_Article_Title (website,article) -> article ^ " - " ^ website
| `Website_MiniCalendar_Go -> "Aller à l'agenda"

| `Website_Count_Subscribers i -> if i = 1 then "Abonné" else "Abonnés"
| `Website_Count_Articles i -> if i = 1 then "Article" else "Articles"
