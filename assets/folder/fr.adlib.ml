| `Folder_File_Info -> "Détails"
| `Folder_File_Download -> "Télécharger"
| `Folder_File_Size mb -> 
  if mb < 0.5 then !! "%.2f Ko" (mb *. 1024.) else
    if mb < 512. then !! "%.2f Mo" mb else
      !! "%.2f Go" (mb /. 1024.) 
| `Folder_File_Comments n -> if n = 1 then "1 commentaire" else !! "%d commentaires" n 
| `Folder_List_Empty -> "Aucun fichier disponible"
| `Folder_ReadOnly -> "Vous ne pouvez pas ajouter de documents" 
