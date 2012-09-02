open Common
open WithSections 

let page url title list =
  let url = "/catalog"^url in
  page url title 
    ~section:"catalog"
    ~head:"catalog"
    ~subsection:url 
    list

(* Gestion des photos
Pour uniformiser la taille des images
exporter depuis flickr en 500x333
paint : réduir à 93%
puis découper à : 465x270 *)
	
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
	(create "Students");

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/gaetan_z/6853069363/",
		       "GaetanZFSHN")
	   "/public/img/preconf_students.jpg")
	(features [ 
	  "Point fort",
	  "Créer et annimez facilement le réseau social privé de votre association étudiante" ;
	    
	  "Idéal pour...",
	  "Organiser vos soirées et partager ensuite les photos entre vous. Gérer l'inscription en ligne de vos membres" ;
	  
	  "Egalement pensé pour...",
	  "Equiper vos projets et vos commissions d'un outil qui leur permettra d'agir plus efficacement."	
	  
	]) ; 
	
	ribbon ( important
		"Ils vont parler de vous !"
		"Offrez à vos étudiants le réseau social privé qu’ils attendent de leur asso et de leur école") ;

	(pride 
	   ~title:"Le réseau privé de votre asso"
	   "Notre solution dédiée aux associations étudiantes (BDE, BDA, BDS, etc.) vous permet d'équiper votre asso d'un outil de communication et d’organisation complet et puissant. Vous organisez en quelques minutes vos évènements et soirées, offrez des espaces de discussions et d’échanges privés (fini les photos sur Internet !), équipez vos clubs et projets. Cet espace en ligne devient le site communautaire pour organiser votre asso et pour tous vos étudiants.

De plus, vous gagnez du temps car vous profitez des facilités vos étudiants et vos bénévoles à communiquer via les réseaux sociaux pour alléger considérablement vos tâches administratives et logistiques"
	) ; 

      hr () ;

      composite `LR
	(price
	   "Gratuit"
	   "pour les assos étudiantes"
	   "de moins de 8000 adhérents") 
	(bullets
	   ~title:"La plateforme la plus complète"
	   ~subtitle:"Tous les outils utiles regroupés dans un même espace"
	   ~ordered:false
	   [ "Communication interne via l'espace membre" ;
	     "Communication externe via le site Internet" ;
	     "Outils de gestion et d'organisation collaboratifs" ;
	     "Hébergement, mises à jour et maintenance informatique" ]
	) ;
    ] ; 
	
  page "/asso/Ess" "RunOrg Associations - Economie Sociale et Solidaire"
    [ composite `LR
	(pride ~title:"Associations de l'ESS" "Pour toutes les associations de l'économie sociale et solidaire")
	(create "Ess")
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/leo-gruebler/6347903993/",
		       "Leo Gruebler")
	   "/public/img/preconf_ess.jpg")
	(features [ 
	  "Point fort",
	  "Communiquez, organiser et mobilisez depuis un seul et même espace" ;
	    
	  "Idéal pour...",
	  "Mobiliser très rapidement tous les membres pour une action commune et pour communiquer de manière transversale" ;
	  
	  "Egalement pensé pour...",
	  "- Travailler de manière collaborative sur des idées ou des actions  - Garder confidentiel les échanges entre les membres"	
	  	  
	]) ; 


	(pride 
	   ~title:"L'ESS a enfin son outil !"
	   "La solution dédiée aux Associations de l'Economie Sociale et Solidaire (ESS) est conçue pour les aider à s'organiser au mieux dans un environnement démocratique et collaboratif.

Les membres s'organisent autour de projets, de thèmes ou encore d'actions. Chacun des groupes ainsi constitué peut avancer sur ses sujets sans interférer avec la communication globale au sein de l'association.  Les membres on néanmoins accès à tous les sujets qui les intéressent et peuvent apporter leur contribution.

RunOrg Association Economie Sociale et Solidaire vous offre une solution clef en main, ludique et efficace pour organiser vos activité et vos action. De plus vous bénéficiez de tous les autres points forts de RunOrg pour la gestion de vos membres."
	) ; 

      hr () ;

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
	) ;
    ] ;

  page "/asso/Impro" "RunOrg Associations - Théâtre d'Improvisation"
    [ composite `LR
	(pride ~title:"Troupes et clubs d'Improvisation" "Spécialement créé pour les troupes et les clubs pratiquant le théâtre d'improvisation")
	(create "Impro")     ;
	
    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/cyberuly/5370448834/",
		       "Cyberuly")
	   "/public/img/preconf_impro.jpg")
	(features [ 
	  "Points forts",
	  "Facilite l'organisation des activités (matchs et entrînements) en permettant de réccupérer les disponibilités des joueurs" ;
	    
	  "Idéal pour...",
	  "Organiser les matchs et les spectacles grâce aux modèles d'activités dédiés" ;
	  
	  "Déjà utilisé par...",
	  "Les fondateurs de RunOrg et leur troupe d'impro ! (Donc nous prenons grand soin de cette solution !)"	
	  
	]) ; 

	(pride 
	   ~title:"N'improvisez plus l'organisation !"
	   "La solution Théâtre d'improvisation de RunOrg vous permet de bénéficier d'une solution créée spécialement pour répondre aux besoins des troupes d'improvisation professionnelles ou amateures. 

Cette solution a été pensée pour vous aider dans l'organisation de vos matchs, de vos spectacles et de vos entraînements.

En un seul endroit vous centralisez les informations sur vos joueurs, les entrainements, les cotisations, les spectacles, les matchs, les supporteurs. De plus les modèles RunOrg pour le théâtre d'improvisation vous permettent de bénéficier de check liste pour vous faciliter l'organisation de vos événements.

Jamais organiser un spectacle, inviter votre public et partager ensuite les photos n'a été aussi simple. Tout cela dans l'environnement sécurisé RunOrg."
	) ; 

      hr () ;

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
	) ;
    ] ;

  page "/clubs-sports/MultiSports" "RunOrg Clubs - Clubs multi-sports "
    [ composite `LR
	(pride ~title:"Clubs multi-sports" "Une solution adaptée au fonctionnement des clubs multi-sports")
	(create "MultiSports")
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/loozrboy/3024154654/",
		       "Loozrboy")
	   "/public/img/preconf_multisports.jpg")
	(features [ 
	  "Point forts",
	  "Permet de gérer tous les sports de son club en utilisant un seul outil" ;
	    
	  "Idéal pour...",
	  "Gérer plusieurs sports au sein d'un même club et offrir à chacun un espace d'organisation indépendant" ;
	  
	  "Egalement pensé pour...",
	  "Offrir des formulaires d'inscription différenciés pour chacun des sports (inclus et mis à jour)"	
	  
	]) ; 
	
	(pride 
	   ~title:"Votre intranet organisé par activités"
	   "La solution Club multi-sports de RunOrg vous permet de bénéficier d'un intranet conçu pour répondre aux nombreux et complexes besoins des clubs offrants plusieurs sports à leurs membres. 

Cette solution vous permet de bénéficier depuis une seul espace de tous les formulaires sportifs créés pour les sports déjà préconfigurés dans RunOrg. Elle vous permet d’offrir à vos différentes disciplines des espaces dédiés dans lesquels les membres vont pouvoir communiquer et s’organiser. Elle prend en compte qu’un membre peut participer à plusieurs sports et permet de gérer des adhésions différentiées selon les sports.

RunOrg Club multi-sports vous offre une solution clef en main, ludique et efficace pour gérer les activités, les évènements et les différentes structures sportives au sein de votre club. De plus vous bénéficiez de tous les autres points forts de RunOrg pour la gestion d’une communauté en ligne. "
	) ; 

      hr () ;

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
	) ;
    ] ;

  page "/clubs-sports/Judo" "RunOrg Clubs - Judo et Jujitsu"
    [ composite `LR
	(pride ~title:"Clubs de Judo et Jujitsu" "Solution conçue avec des entraîneurs et des clubs de haut niveau")
	(create "Judo")
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/parrhesiastes/",
		       "Parrhesiastes")
	   "/public/img/preconf_judo.jpg")
	(features [ 
	  "Points forts",
	  "Facilite la communication au sein du clubs et les tâches administratives des responsables" ;
	    
	  "Idéal pour...",
	  "Gérer les inscriptions, organiser les compétitions, communiquer avec les sportifs ou leurs parents" ;

	  "Modèles et groupes inclus",
	  "Formulaires d'inscription, classification par âge du judo, compétition de judo"	
	  
	]) ; 

	(pride 
	   ~title:"Plus qu'un outil : une communauté"
	   "La solution RunOrg pour les club de judo et jujitsu a été conçue en se basant sur les besoins et les conseils de clubs de judo évoluant au plus haut niveau. Son objectif est de faciliter l'organisation des entraînements et des compétitions et de mettre en avant les valeurs du club et du judo.

Grâce à son formulaire spécial judo et jujitsu (comportant les ceintures réglementaires, les dans et les questions relatives aux judokas) et la livraison en standard des groupes de niveau du judo (du petit samouraï au vétéran), vous disposez d'une solution déjà complètement personnalisée aux besoins des clubs de judo et jujitsu.

Offrez à votre club l'espace communautaire en ligne qui va pouvoir être utilisé pour faciliter sa communication et son organisation, mais aussi renforcer ses valeurs et la cohésion de ses membres."
	) ; 

      hr () ;

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
	) ;
    ] ;

	page "/clubs-sports/Badminton" "RunOrg Clubs - Badminton "
    [ composite `LR
	(pride ~title:"Clubs de Badminton" "Solution élaborée avec le concours de la Fédération Française de Badminton")
	(create "Badminton")
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/cdianne/2725181343/",
		       "Dee'lite")
	   "/public/img/preconf_badminton.jpg")
	(features [ 
	  "Point fort",
	  "Gestion du loisir et du haut niveau en lien avec la FFBAD" ;

	  "Modèles et groupes inclus",
	  "Compétition de badminton, formualaire d'inscription badminton, groupes pour le loisir, la compétition et les entraîneurs ";	
	  
	  "Déjà utilisé par...",
	  "Les clubs affiliés à la Fédération Française de Badminton"	
	  
	]) ; 
	
	ribbon ( important
		"Solution approuvée par la FFBAD"
		"") ;

      composite `LR
	(image "/public/img/preconf_badminton_logo_ffbad.jpg")
	(pride
	   ~title:"Portail clubs de la FFBAD"
	   ~subtitle:"Bientôt disponible"
	   ~link:("/http://www.ffbad.org",
	       "Site de la FFBAD")
	   "La FFBAD met à la disposition exclusive de ses clubs affiliés des espaces privés spécialements adaptés au badminton. 
	   Ces espaces sont hébergés sous le nom de domaine de la fédération, disposent des couleurs de la FFBAD, et fourniront des services exclusifs aux clubs affiliés."
	) ;

      hr () ;

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
	) ;
    ] ;	

  page "/clubs-sports/Footus" "RunOrg Clubs - Football US & cheerleading "
    [ composite `LR
	(pride ~title:"Clubs de Football US & cheerleading" "Solution utilisée notamment par un club évoluant en ELITE")
	(create "Footus") 
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/virtualsugar/3967883513/",
		       "Monica's Dad")
	   "/public/img/preconf_footus.jpg")
	(features [ 
	  "Point fort",
	  "De l'inscription des membres à l'organistion des matchs dans un seul outil." ;
	    
	  "Idéal pour...",
	  "Motiver les joueurs et communiquer sur les résultats !" ;
	  
	  "Modèles et groupes inclus",
	  "Groupes des niveaux officiels, formulaires d'inscription Football US et cheerleading"	

	]) ; 

	(pride 
	   ~title:"Conçu avec les meilleurs"
	   "La solution RunOrg pour les clubs de football américain et cheerleading a été conçue en se basant sur les besoins et les conseils de clubs évoluant au plus haut niveau. Son objectif est de faciliter l'organisation des entraînements et des compétitions et de mettre en avant les valeurs du club.

Grâce à ses formulaires spéciaux football américain et cheerleading (comportant notamment les positions)  vous disposez d'une solution déjà personnalisée aux besoins des clubs football américain et cheerleading.

Offrez à votre club l'espace communautaire en ligne qui va pouvoir être utilisé pour faciliter sa communication et son organisation, mais aussi renforcer ses valeurs et la cohésion de ses membres."
	) ; 

      hr () ;

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

  page "/clubs-sports/Athle" "RunOrg Clubs - Athlétisme "
    [ composite `LR
	(pride ~title:"Clubs d'Athlétisme" "")
	(create "Athle")
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/virtualsugar/3967883513/",
		       "GiÃ¥m")
	   "/public/img/preconf_athle.jpg")
	(features [ 
	  "Point fort",
	  "Gérer er organiser les différentes disciplines et leurs sportifs n'a jamais été aussi simple" ;
	    
	  "Idéal pour...",
	  "Différencier la communication et l'organisation des activités par disciplines" ;
	  
	  "Egalement pensé pour...",
	  "Offrir aux sportifs et leurs parents un lieu d'échanges et de conseils."	
	  	  
	]) ; 

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

  page "/clubs-sports/SalleSport" "RunOrg Clubs - Salle de sport et coaching "
    [ composite `LR
	(pride ~title:"Salle de sport et coaching sportif" "Solution développée en collaboration avec un coach sportif et un gestionnaire de salle de sport")
	(create "SalleSport")    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/abraj/181196330/",
		       "Abdullah AL-Naser")
	   "/public/img/preconf_sallesport.jpg")
	(features [ 
	  "Points forts",
	  "Personnalisation du suivi des sportifs" ;
	    
	  "Idéal pour...",
	  "Organiser les activités et les suivis avec plusieurs sportifs et entraineurs " ;
	 	  
	  "Modèles et groupes inclus",
	  "Cours incluant les objectifs, modèles de bilan sportifs, formulaire d'inscription détaillés"	
	  
	]) ; 
	

	(pride 
	   ~title:"Personnalisez le suivi des sportifs"
	   "La solution de RunOrg dédiée aux salles de sport et aux coachs sportifs est conçue pour les aider à s'organiser au mieux pour répondre aux besoins et attentes des sportifs qu'ils entraînent. 

Même dans un environnement avec plusieurs profs, Les sportifs bénéficient d'un suivi personnalisé et centralisé de leurs activités, de leurs cours et de leur progression. Ils disposent en plus d'un espace d'échange privilégié avec leurs entraineurs et leurs conseillers. Vous proposez à vos sportifs de rejoindre des groupes (intérêts, cours, etc.) dans lesquels ils vont pouvoir communiquer. Des modèles vous permettent de réaliser des bilans réguliers de leurs performances.

RunOrg Salles de sport et coaching sportif vous offre une solution clef en main, ludique et efficace pour organiser vos activités et vos actions. De plus vous bénéficiez de tous les autres points forts de RunOrg pour la gestion de vos membres."
	) ; 

      hr () ;

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

  page "/clubs-sports/Sports" "RunOrg Clubs - Autres sports"
    [ composite `LR
	(pride ~title:"Autres clubs de sports" "Solution standard pour les clubs de sports n'ayant pas encore de configuration dédiée")
	(create "Sports")   ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/zachd1_618/6724055197/",
		       "Zach Dischner")
	   "/public/img/preconf_sports.jpg")
	(features [ 
	  "Point fort",
	  "Adapté à la plupart des besoins des clubs de sports" ;
	    
	  "Idéal pour...",
	  "Communiquer et organiser l'activité de son club" ;

	  "Modèles et groupes inclus",
	  "Groupes de niveaux"	

	]) ; 
	
	ribbon ( important
		"Contactez-nous !"
		"La solution pour votre sport n'existe pas encore ?
		Contactez-nous pour que nous la construisions ensemble !") ;

	(pride 
	   ~title:"Adapté à la plupart des sports !"
	   "La solution Club de sport de RunOrg vous permet de bénéficier d'un intranet créé pour s'adapter à un très grand nombre de cas et de besoins de clubs de sport.

Cette solution peut très facilement s’adapter pour répondre aux besoins de tous les sports dans le cadre de club mono-sport. Elle incorpore en standard les catégories sportives les plus utilisées. Sa prise en main rapide vous permet de l'adopter très rapidement.

C'est cette configuration que nous vous conseillons s’il n’existe pas encore de préconfiguration dédiée à votre sport. De plus, nous pourrons vous « migrer » gratuitement vers celle conçue pour votre sport dès qu’elle sera disponible. 

N’hésitez pas à nous contacter pour que nous aider à concevoir la solution pour votre sport !"
	) ; 

      hr () ;

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

  page "/collectivites/Collectivites" "RunOrg Collectivités - Mairies et collectivités territoriales"
    [ composite `LR
	(pride ~title:"Mairies et collectivités territoriales" "Solution dédiée aux mairies, communautés de communes et autres collectivités territoriales")
	(create "Collectivites")   ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/26700188@N05/5633798012/",
		       "Besopha")
	   "/public/img/preconf_collectivites.jpg")
	(features [ 
	  "Point fort",
	  "Modernisation de la communication sans modification de l'organisation" ;
	    
	  "Idéal pour...",
	  "Faciliter la communication inter-service, notamment autour de projets ou d'évènements" ;
	  
	  "Egalement pensé pour...",
	  "Déléguer aux responsables la gestion de l'espace dédié à leur service"	

	]) ; 

	(pride 
	   ~title:"L'outil s'adapte à votre organisation"
	   "Pour les collectivités territoriales nous proposons un intranet collaboratif qui s’adapte à leur organisation existante et à prix très compétitif.
 
Tous les agents ont accès à un espace privé et sécurisé qui centralise la communication interne. Les différents services disposent d’espace privés, dont l’administration peut être déléguée aux responsables.

Les services disposent d'un annuaire en ligne, d'un agenda partagé des évènements et des réunions, de la possibilité d'échanger de manière sécurisé des documents, et de les partager aux seins de groupes restreins.
"
	) ; 

      hr () ;

      composite `LRR
	(price
	   ~title:"La technologie accessible"
	   ~subtitle:"L'offre la plus économique du marché"
	   ~link:("/pricing",
		  "Tarifs des offres") 
	   "Nous vous offrons un outil à la pointe, adaptable et évolutif. 
	   
	   Opter pour une solution déjà existante et en ligne est un choix économiquement plus judicieux et plus sûr que de développer ou faire développer sa solution. 
	   
	   Vous êtes dès maintenant en mesure d'évaluer la qualité de l'outil et notre offre tarifaire claire vous permet de connaître précisément les coûts annuels, sans surprise. "
	) 
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

  page "/collectivites/LocalNpPortal" "RunOrg Collectivités - Portail associatif communal"
    [ composite `LR
	(pride ~title:"Portail associatif communal" "Dotez gratuitement votre commune d'un outil pour organiser efficacement ses associations")
	(create "LocalNpPortal")(*
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/mattymatt/4821997419/",
		       "Mattymatt")
	   "/public/img/preconf_localnpportal.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/collectivites/MaisonAsso" "RunOrg Collectivités - Maisons des associations"
    [ composite `LR
	(pride ~title:"Maisons des associations" "Equipez gratuitement votre MDA d'un outil pour accompagner et annimer facilement ses associations")
	(create "MaisonAsso")(*
    ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/papalars/3250085382/",
		       "Papalars")
	   "/public/img/preconf_maisonasso.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;	

  page "/collectivites/Campaigns" "RunOrg Collectivités - Campagnes électorales"
    [ composite `LR
	(pride ~title:"Campagnes électorales" "Un moyen efficace et original de mener sa campagne. Utilisé par plusieurs députés élus en 2012.")
	(create "Campaigns")(*
    ;
http://www.flickr.com/photos/beraldoleal/4857977087/
http://www.flickr.com/photos/pinksherbet/236299644/
http://www.flickr.com/photos/wwworks/4005631298/
	
    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/stevebott/2805560252/",
		       "Stevebott")
	   "/public/img/preconf_campaigns.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;	

  page "/federations/Federations" "RunOrg Fédérations - Structure fédérale"
    [ composite `LR
	(pride ~title:"Fédérations" "Solution standard pour organiser en ligne la structure fédérale des fédérations.")
	(create "Federations") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/-cavin-/2366764272/",
		       "Cаvin")
	   "/public/img/preconf_federations.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/federations/Badminton" "RunOrg Fédérations - FF Badminton"
    [ composite `LR
	(pride ~title:"FF Badminton" "Solution conçue et adaptée pour les clubs affiliés à la Fédération Française de Badminton")
	(create "Badminton") ;

      composite `LR
	(image "/public/img/preconf_badminton_logo_ffbad.jpg")
	(pride
	   ~title:"Portail clubs de la FFBAD"
	   ~subtitle:"Bientôt disponible"
	   ~link:("http://www.ffbad.org",
	       "Site de la FFBAD")
	   "La FFBAD met à la disposition exclusive de ses clubs affiliés des espaces privés spécialements adaptés au badminton. 
	   Ces espaces sont hébergés sous le nom de domaine de la fédération, disposent des couleurs de la FFBAD, et fourniront des services exclusifs aux clubs affiliés."
	);
    ] ;	

  page "/federations/SpUsep" "RunOrg Fédérations - USEP "
    [ composite `LR
	(pride ~title:"USEP" "-En test- Solution conçue et adaptée pour les associations affiliées à l'USEP")
	(create "SpUsep")
    ] ;	

  page "/federations/SectionSportEtudes" "RunOrg Fédérations - Sections sport-études"
    [ composite `LR
	(pride ~title:"Sections sport-études" "Conçu avec et pour le pôle espoir de la ligue de judo Rhône Alpes, cette solution d'adapte à toutes les sections sport-études.")
	(create "SectionSportEtudes") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/jayhem/3600002571/",
		       "Jayhem")
	   "/public/img/preconf_sectionsportetudes.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/education/ElementarySchool" "RunOrg Education - Ecoles primaires "
    [ composite `LR
	(pride ~title:"Ecoles primaires" "Elaboré avec le concours de spécialistes du numérique dans l'éducation, d'écoles, d'instituteurs et d'associations")
	(create "ElementarySchool") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/wwworks/4005631298/",
		       "Woodleywonderworks")
	   "/public/img/preconf_elementaryschool.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/education/SectionSportEtudes" "RunOrg Education - Sections sport-études"
    [ composite `LR
	(pride ~title:"Sections sport-études" "Conçu pour organiser et animer depuis un seul espace les encadrants, élèves, professeurs et parents")
	(create "SectionSportEtudes")
    ] ;	

  page "/syndic-copropriete/Copro" "RunOrg Copropriétés - Copropriété avec syndic professionnel"
    [ composite `LR
	(pride ~title:"Copropriété avec syndic professionnel" "Gestion d'une copropriété avec un gestionnaire ou un syndic professionnel")
	(create "Copro") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/joiseyshowaa/1279750389/",
		       "Joiseyshowaa")
	   "/public/img/preconf_copro.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/syndic-copropriete/CoproVolunteer" "RunOrg Copropriétés - Copropriété avec syndic bénévole"
    [ composite `LR
	(pride ~title:"Copropriété avec syndic bénévole" "Gestion d'une copropriété en syndic bénévol ou regroupement de copropriétaires sans accès pour le syndic professionnel")
	(create "CoproVolunteer") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/gdominici/93513921/",
		       "Gianni Dominici")
	   "/public/img/preconf_coprovolunteer.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/entreprises/Company" "RunOrg Entreprises"
    [ composite `LR
	(pride ~title:"Entreprises" "Solution simple et flexible à la manière d'un Réseau Social d'Entreprise")
	(create "Company") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/proimos/4045973322/",
		       "Alex E. Proimos")
	   "/public/img/preconf_company.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/entreprises/CompanyTraining" "RunOrg Entreprises - Centres de formation"
    [ composite `LR
	(pride ~title:"Centres de formation" "Solution idéale pour organiser les échanges entre les stagiaires et garder le contact avec eux une fois la formation terminée")
	(create "CompanyTraining") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/76029035@N02/6829406809/",
		       "Victor1558")
	   "/public/img/preconf_companytraining.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;
	
  page "/ComiteEnt" "RunOrg Comités d'Entreprise"
    [ composite `LR
	(pride ~title:"Comités d'Entreprise" "Solution conçue pour organiser et annimer des comités de petites et moyennes entreprises" )
	(create "ComiteEnt") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/highwaysagency/5998133376/",
		       "Highways Agency")
	   "/public/img/preconf_comiteent.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] ;

  page "/others/Events" "RunOrg - Organisation d'évènements"
    [ composite `LR
	(pride ~title:"Organisation d'évènements" "Cette solution vous permet d'organiser un évènement, d'animer les participants, et de les relancer pour les évènements suivants")
	(create "Events") (* ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/pagedooley/3194564161/",
		       "Kevin Dooley")
	   "/public/img/preconf_events.jpg")
	(features [ 
	  "Point fort",
	  "" ;
	    
	  "Idéal pour...",
	  "" ;
	  
	  "Egalement pensé pour...",
	  ""	
	  
	  "Modèles et groupes inclus",
	  ""	
	  
	  "Déjà utilisé par...",
	  ""	
	  
	]) ; 
	
	ribbon ( important
		""
		"") ;

	(pride 
	   ~title:""
	   ""
	) ; 

      hr () ;

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
	); *)
    ] 
	       
  (* END PAGES -------------------------------------------------------------- *)
] 
