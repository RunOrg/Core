| `Digest_Title (y,m,d) -> !! "Actualités du %02d %s" d
  [| "Janvier" ; "Février" ; "Mars" ; "Avril" ; "Mai" ; "Juin" ;
     "Juillet" ; "Août" ; "Septembre" ; "Octobre" ; "Novembre" ; "Décembre" |].(m-1)

| `Digest_Body -> "Ce courrier vous est envoyé automatiquement tous les deux jours s'il reste des messages non lus dans une communauté dont vous êtes membre."

| `Digest_Unread (what,n) -> begin
  match what with 
  | `Wall -> if n = 1 then "nouveau message" else "nouveaux messages"
  | `Folder -> if n = 1 then "nouveau document" else "nouveaux documents"
  | `Album -> if n = 1 then "nouvelle photo" else "nouvelles photos"
end
