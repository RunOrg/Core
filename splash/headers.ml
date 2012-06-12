open Common 

let headers = [
  (* BEGIN HEADERS ---------------------------------------------------------- *)

  header "associations" 
    ~title:"L'intranet de votre association"
    ~text:"Un outil collaboratif en ligne pour gérer plus facilement les membres, les adhésions, les activités et la communication de votre association."
    ~trynow:( "Essayer Gratuitement", "/start/1/v:simple" ) 
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
    ~trynow:("Explorez le réseau !","/network/explore") 
    [ "Pour les membres",      "membres",      "/network" ;
      "Pour les associations", "associations", "/network/asso" 
    ] ;

  header "network-asso"
    ~title:"Le réseau des associations"
    ~text:"Un annuaire et un réseau social qui donne la parole aux associations, aux fédérations et à l'écosystème associatif."
    ~trynow:("Créez votre profil !","/start/1/v:simple") 
    [ "Pour les membres",      "membres",      "/network" ;
      "Pour les associations", "associations", "/network/asso" 
    ] ;


(*  header "collectivites" 
    ~title:"Des intranets pour votre collectivité"
    ~text:"Des plateformes collaboratives spécialement adapatées pour gérer et communiquer avec vos agents, vos administrés, vos associations et vos sympathisants"
    ~trynow:( "Essayer Gratuitement", "/catalog#collec" ) 
    [ "Accueil",         "accueil",         "/collectivites" ;
      "Avantages",       "avantages",       "/collectivites/benefits";
      "Fonctionnalités", "fonctionnalites", "/collectivites/features";
      "Tarifs", "pricing-collectivites", "/collectivites/pricing";
    ] ; *)

   
  (* END HEADERS ------------------------------------------------------------ *)
]
