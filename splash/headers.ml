open Common 

let headers = [
  (* BEGIN HEADERS ---------------------------------------------------------- *)

  header "associations" 
    ~title:"L'intranet de votre association"
    ~text:"Un outil collaboratif en ligne pour gérer plus facilement les membres, les adhésions, les activités et la communication de votre association."
    ~trynow:( "Essayer Gratuitement", "/start/Simple" ) 
    [ "Accueil",         "accueil",         "/" ;
      "Avantages",       "avantages",       "/associations/benefits";
      "Fonctionnalités", "fonctionnalites", "/features";
    ] ;

  header "about" 
    ~title:"À propos de RunOrg"
    ~text:"Découvrez l'équipe qui se cache derrière le projet !"
    ~trynow:( "Nous Contacter", "/contact" ) 
    [ "Projet", "projet", "/about" ;
      "Équipe", "equipe", "/about/team" ;
    ] ;

  header "cgu" 
    ~title:"Mentions Légales"
    ~text:"Ici, toutes les informations d'ordre juridique."
    ~trynow:( "Nous Contacter",  "/contact" ) 
    [ "RunOrg SARL", "mentions", "/mentions-legales" ;
      "CGU et CGV",  "cgu",      "/cgu-cgv" ;
      "Vie Privée",  "privacy",  "/privacy" ;
    ] ;

  header "accompagnement" 
    ~title:"Nos offres d'accompagnement"
    ~text:"Profitez de notre expertise pour installer et accompagner l'espace privé RunOrg de votre organisation."
    [] ;

  header "press" 
    ~title:"Presse"
    ~text:"Ici, toutes les informations pour la presse"
    ~trynow:( "Nous Contacter", "/contact" ) 
    ["Dossiers",    "press",          "/press" ;
     "Communiqués", "press-releases", "/press/releases"  ;
   ];
  
  header "pricing" 
    ~title:"Les tarifs"
    ~text:"L'offre la plus compétitive du marché ! 
    Des tarifs adaptés à vos besoins et à votre organisation."
    [] ;   

  header "network"
    ~title:"Le réseau des associations"
    ~text:"Un annuaire et un réseau social qui donne la parole aux associations, aux fédérations et à l'écosystème associatif."
    ~trynow:("Explorez le réseau !","/network/all") 
    [ "Pour les membres",      "membres",      "/network" ;
      "Pour les associations", "associations", "/network/asso" 
    ] ;

  header "network-asso"
    ~title:"Le réseau des associations"
    ~text:"Un annuaire et un réseau social qui donne la parole aux associations, aux fédérations et à l'écosystème associatif."
    ~trynow:("Créez votre profil !","/start/Simple") 
    [ "Pour les membres",      "membres",      "/network" ;
      "Pour les associations", "associations", "/network/asso" 
    ] ;

  multiheader "catalog"
    ~title:"Catalogue"
    ~text:"Toutes les configurations disponibles pour votre espace RunOrg pour mieux répondre à vos besoins."
    [ "Associations", "/catalog", 
      [ "Standard",              "/catalog" ;
	"Associations étudiantes", "/catalog/asso/Students" ;
	"Economie Sociale et Solidaire", "/catalog/asso/Ess" ;
	"Théâtre d'improvisation", "/catalog/asso/Impro"
      ] ;
	  "Clubs de sport", "/catalog/clubs-sports/MultiSports", 
		["Clubs multi-sports", "/catalog/clubs-sports/MultiSports" ;
		"Judo et jujitsu", "/catalog/clubs-sports/Judo" ;
		"Badminton", "/catalog/clubs-sports/Badminton" ;
		"Football US & cheerleading", "/catalog/clubs-sports/Footus" ;
		"Athlétisme", "/catalog/clubs-sports/Athle" ;
		"Salle de sport et coaching", "/catalog/clubs-sports/SalleSport" ;
		"Autre", "/catalog/clubs-sports/Sports" 
		] ;
	  "Collectivités", "/catalog/collectivites/Collectivites" ,
	  [ "Mairies & collectivités", "/catalog/collectivites/Collectivites";
	  "Portail associatif communal", "/catalog/collectivites/LocalNpPortal";
	  "Maison des associations", "/catalog/collectivites/MaisonAsso" ;
	  "Campagnes électorales", "/catalog/collectivites/Campaigns"
	  ];
	  "Fédérations", "/catalog/federations/Federations", 
	  [ "Fédérations", "/catalog/federations/Federations" ;
	  "FF Badminton", "/catalog/federations/Badminton" ;
	  "USEP", "/catalog/federations/SpUsep" ;
	  "Sections sport-études", "/catalog/federations/SectionSportEtudes"
	  ] ;
	  "Education", "/catalog/education/ElementarySchool", 
	  [ "Ecoles primaires" , "/catalog/education/ElementarySchool" ;
	  "Sections sport-études", "/catalog/education/SectionSportEtudes"
	  ] ;
	  "Copropriétés", "/catalog/syndic-copropriete/Copro", 
	  [ "Copropriété avec syndic professionnel", "/catalog/syndic-copropriete/Copro" ;
	  "Copropriété avec syndic bénévole", "/catalog/syndic-copropriete/CoproVolunteer"
	  ] ;
	  "Entreprises", "/catalog/entreprises/Company", 
	  [ "Entreprises", "/catalog/entreprises/Company" ;
	  "Centres de formation", "/catalog/entreprises/CompanyTraining"
	  ] ;
      "Comités d'entreprise", "/catalog/ComiteEnt", [] ;
      "Autres", "/catalog/others/Events", 
	  [ "Organisation d'évènements", "/catalog/others/Events" 
	  ] ;
    ] ;

	header "collectivites" 
    ~title:"L'espace numérique de votre collectivité"
    ~text:"Des plateformes collaboratives spécialement adapatées pour gérer et communiquer avec vos agents, vos administrés, vos associations et vos sympathisants"
    ~trynow:( "Essayer Gratuitement", "/catalog#collectivites" ) 
    [ "Accueil",         "accueil",         "/collectivites" ;
      "Offres",       "offres",       "/collectivites/products";
      "Fonctionnalités", "fonctionnalites", "/collectivites/features";
      "Tarifs", "pricing-collectivites", "/collectivites/pricing";
    ] ; 

	header "entreprises" 
    ~title:"L'espace numérique 2.0 de votre entreprise"
    ~text:"Des plateformes collaboratives spécialement adapatées pour gérer et communiquer avec vos salariés, clients, fournisseurs ou abonnés."
    ~trynow:( "Essayer Gratuitement", "/catalog#company" ) 
    [ "Accueil",         "accueil",         "/entreprises" ;
      "Offres",       "offres",       "/entreprises/products";
      "Fonctionnalités", "fonctionnalites", "/entreprises/features";
      "Tarifs", "pricing-collectivites", "/entreprises/pricing";
    ] ;

   
  (* END HEADERS ------------------------------------------------------------ *)
]
