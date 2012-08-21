| `Upload_Submit -> "Envoyer"
| `Upload_Cancel -> "Annuler"
| `Upload_Doc_Submit -> "Publier"

| `Album_Size_Remaining -> "Espace disponible" 
| `Album_Size mb ->
  if mb < 0.5 then !! "%.2f Ko" (mb *. 1024.) else
    if mb < 512. then !! "%.2f Mo" mb else
      !! "%.2f Go" (mb /. 1024.) 
| `Album_Upload -> "Ajouter des photos"
