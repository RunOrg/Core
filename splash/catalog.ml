open Common
open WithSections 

let page url title list =
  let url = "/catalog"^url in
  page url title 
    ~section:"catalog"
    ~head:"catalog"
    ~subsection:url 
    list

let pages = [
  (* BEGIN PAGES ------------------------------------------------------------ *)

  page "" "RunOrg Associations - Configuration Standard"
    [ composite `LR
	(pride ~title:"Configuration standard" "Description")
	(create "Simple")
    ] ;

  page "/asso/Students" "RunOrg Associations - BDE et Associations Etudiantes"
    [ pride ~title:"BDE & Etudiants" "Description" ] ;

  page "/ComiteEnt" "RunOrg Comités d'Entreprise"
    [ pride ~title:"Comités d'Entreprise" "Description" ]
        
  (* END PAGES -------------------------------------------------------------- *)
] 
