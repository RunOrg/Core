| `Import_ByEmail_Step1 -> "Entrez la liste des membres à inscrire"
| `Import_ByEmail_Continue -> "Étape Suivante"
| `Import_ByEmail_Step2 -> "Vérifiez le contenu de la liste"
| `Import_Column_Email -> "E-mail"
| `Import_Column_Firstname -> "Prénom"
| `Import_Column_Lastname -> "Nom"
| `Import_ByEmail_Submit -> "Inscription"

| `Import_ByGroup_Selected -> "Groupes sélectionnés"
| `Import_ByGroup_Submit how -> begin 
  match how with 
    | `Add    -> "Inscrire les membres de ces groupes"
    | `Invite -> "Inviter les membres de ces groupes"
end 

| `Import_Help_FromExcel -> "Depuis un tableur"
| `Import_Help_FromExcel_Detail -> "Créez trois colonnes email, prénom et nom, dans cet ordre, puis sélectionnez-les et copiez-collez leur contenu dans la case ci-contre." 
| `Import_Help_FromBook -> "Depuis un carnet d'adresses"
| `Import_Help_FromBook_Detail -> "Vous pouvez également utiliser le format"
| `Import_Help_FromBook_Example -> "Prénom Nom <adresse@email.com>" 
| `Import_Help_Check -> "Validation préalable"
| `Import_Help_Check_Detail -> "Vous pourrez vérifier et corriger la liste des membres avant leur inscription."

| `Import_ByEmail -> "Par e-mail"
| `Import_ByName -> "Par nom"
| `Import_ByGroup -> "Par groupe"
