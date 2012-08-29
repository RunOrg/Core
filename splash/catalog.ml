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
	(pride ~title:"Configuration standard" "Une configuration généraliste adaptée à toutes les associations")
	(create "Simple") ;
	
      composite `LR
	(price
	   "Gratuit"
	   "pour les associations"
	   "de moins de 2000 adhérents") 
	(bullets
	   ~title:"La plateforme la plus complète"
	   ~subtitle:"Tous les outils utiles regroupés dans un même espace"
	   ~ordered:false
	   [ "Communication interne via l'espace membre" ;
	     "Communication externe via le site Internet" ;
	     "Outils de gestion et d'organisation collaboratifs" ;
	     "Hébergement, mises à jour et maintenance informatique" ]
	); 
    ] ;
	
  page "/asso/Students" "RunOrg Associations - BDE et Associations Etudiantes"
   [ composite `LR
	(pride ~title:"Associations étudiantes" "Pour les BDE, les BDA, les BDS et toutes les associations étudiantes")
	(create "Students")
    ] ;
	
  page "/asso/Ess" "RunOrg Associations - Economie Sociale et Solidaire"
    [ composite `LR
	(pride ~title:"Associations de l'Economie Sociale et Solidaire" "Pour toutes les associations de l'économie sociale et solidaire")
	(create "Ess")
    ] ;

  page "/asso/Impro" "RunOrg Associations - Théâtre d'Improvisation"
    [ composite `LR
	(pride ~title:"Troupes et clubs d'Improvisation" "Spécialement créé pour les troupes et les clubs pratiquant le théâtre d'improvisation")
	(create "Impro")
    ] ;	

  page "/clubs-sports/MultiSports" "RunOrg Clubs - Clubs multi-sports "
    [ composite `LR
	(pride ~title:"Clubs multi-sports" "Une solution adaptée au fonctionnement des clubs multi-sports")
	(create "MultiSports")
    ] ;	

  page "/clubs-sports/Judo" "RunOrg Clubs - Judo et Jujitsu"
    [ composite `LR
	(pride ~title:"Clubs de Judo et Jujitsu" "Solution conçue avec des entraîneurs et des clubs de haut niveau")
	(create "Judo")
    ] ;	

	page "/clubs-sports/Badminton" "RunOrg Clubs - Badminton "
    [ composite `LR
	(pride ~title:"Clubs de Badminton" "Solution élaborée avec le concours de la Fédération Française de Badminton")
	(create "Badminton")
    ] ;	

  page "/clubs-sports/Footus" "RunOrg Clubs - Football US & cheerleading "
    [ composite `LR
	(pride ~title:"Clubs de Football US & cheerleading" "Solution utilisée notamment par un club évoluant en ELITE")
	(create "Footus")
    ] ;	

  page "/clubs-sports/Athle" "RunOrg Clubs - Athlétisme "
    [ composite `LR
	(pride ~title:"Clubs d'Athlétisme" "")
	(create "Athle")
    ] ;	

  page "/clubs-sports/SalleSport" "RunOrg Clubs - Salle de sport et coaching "
    [ composite `LR
	(pride ~title:"Salle de sport et coaching sportif" "Solution développée en collaboration avec un coach sportif et un gestionnaire de salle de sport")
	(create "SalleSport")
    ] ;	

  page "/clubs-sports/Sports" "RunOrg Clubs - Autres sports"
    [ composite `LR
	(pride ~title:"Autres clubs de sports" "Solution standard pour les clubs de sports n'ayant pas encore de configuration dédiée")
	(create "Sports")
    ] ;	

  page "/collectivites/Collectivites" "RunOrg Collectivités - Mairies et collectivités territoriales"
    [ composite `LR
	(pride ~title:"Mairies et collectivités territoriales" "Solution dédiée aux mairies, communautés de communes et autres collectivités territoriales")
	(create "Collectivites")
    ] ;	

  page "/collectivites/LocalNpPortal" "RunOrg Collectivités - Portail associatif communal"
    [ composite `LR
	(pride ~title:"Portail associatif communal" "Dotez gratuitement votre commune d'un outil pour organiser efficacement ses associations")
	(create "LocalNpPortal")
    ] ;	

  page "/collectivites/MaisonAsso" "RunOrg Collectivités - Maisons des associations"
    [ composite `LR
	(pride ~title:"Maisons des associations" "Equipez gratuitement votre MDA d'un outil pour accompagner et annimer facilement ses associations")
	(create "MaisonAsso")
    ] ;	

  page "/collectivites/Campaigns" "RunOrg Collectivités - Campagnes électorales"
    [ composite `LR
	(pride ~title:"Campagnes électorales" "Un moyen efficace et original de mener sa campagne. Utilisé par plusieurs députés élus en 2012.")
	(create "Campaigns")
    ] ;	

  page "/federations/Federations" "RunOrg Fédérations - Structure fédérale"
    [ composite `LR
	(pride ~title:"Fédérations" "Solution standard pour organiser en ligne la structure fédérale des fédérations.")
	(create "Federations")
    ] ;	

  page "/federations/Badminton" "RunOrg Fédérations - FF Badminton"
    [ composite `LR
	(pride ~title:"FF Badminton" "Solution conçue et adaptée pour les clubs affiliés à la Fédération Française de Badminton")
	(create "Badminton")
    ] ;	

  page "/federations/SpUsep" "RunOrg Fédérations - USEP "
    [ composite `LR
	(pride ~title:"USEP" "-En test- Solution conçue et adaptée pour les associations affiliées à l'USEP")
	(create "SpUsep")
    ] ;	

  page "/federations/SectionSportEtudes" "RunOrg Fédérations - Sections sport-études"
    [ composite `LR
	(pride ~title:"Sections sport-études" "Conçu avec et pour le pôle espoir de la ligue de judo Rhône Alpes, cette solution d'adapte à toutes les sections sport-études.")
	(create "SectionSportEtudes")
    ] ;	

  page "/education/ElementarySchool" "RunOrg Education - Ecoles primaires "
    [ composite `LR
	(pride ~title:"Ecoles primaires" "Elaboré avec le concours de spécialistes du numérique dans l'éducation, d'écoles, d'instituteurs et d'associations")
	(create "ElementarySchool")
    ] ;	

  page "/education/SectionSportEtudes" "RunOrg Education - Sections sport-études"
    [ composite `LR
	(pride ~title:"Sections sport-études" "Conçu pour organiser et animer depuis un seul espace les encadrants, élèves, professeurs et parents")
	(create "SectionSportEtudes")
    ] ;	

  page "/syndic-copropriete/Copro" "RunOrg Copropriétés - Copropriété avec syndic professionnel"
    [ composite `LR
	(pride ~title:"Copropriété avec syndic professionnel" "Gestion d'une copropriété avec un gestionnaire ou un syndic professionnel")
	(create "Copro")
    ] ;	

  page "/syndic-copropriete/CoproVolunteer" "RunOrg Copropriétés - Copropriété avec syndic bénévole"
    [ composite `LR
	(pride ~title:"Copropriété avec syndic bénévole" "Gestion d'une copropriété en syndic bénévol ou regroupement de copropriétaires sans accès pour le syndic professionnel")
	(create "CoproVolunteer")
    ] ;	

  page "/entreprises/Company" "RunOrg Entreprises"
    [ composite `LR
	(pride ~title:"Entreprises" "Solution simple et flexible à la manière d'un Réseau Social d'Entreprise")
	(create "Company")
    ] ;	

  page "/entreprises/CompanyTraining" "RunOrg Entreprises - Centres de formation"
    [ composite `LR
	(pride ~title:"Centres de formation" "Solution idéale pour organiser les échanges entre les stagiaires et garder le contact avec eux une fois la formation terminée")
	(create "CompanyTraining")
    ] ;	
	
  page "/ComiteEnt" "RunOrg Comités d'Entreprise"
    [ composite `LR
	(pride ~title:"Comités d'Entreprise" "Solution conçue pour organiser et annimer des comités de petites et moyennes entreprises" )
	(create "ComiteEnt")
	] ;

  page "/others/Events" "RunOrg - Organisation d'évènements"
    [ composite `LR
	(pride ~title:"Organisation d'évènements" "Cette solution vous permet d'organiser un évènement, d'animer les participants, et de les relancer pour les évènements suivants")
	(create "Events")
    ] 
	       
  (* END PAGES -------------------------------------------------------------- *)
] 
