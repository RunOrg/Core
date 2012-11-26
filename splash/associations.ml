open Common
open WithSections 

let page url title list =
  let url = "/"^url in
  page url title 
    ~section:"associations"
    ~head:"associations" 
    ~subsection:url 
    list

(* Gestion des photos
Pour uniformiser la taille des images
exporter depuis flickr en 500x333
paint : réduir à 93%
puis découper à : 465x270 *)
	
let pages = [
  (* BEGIN PAGES ------------------------------------------------------------ *)

 page "" "RunOrg Associations"
 [   composite `LLR
	(video 
	   ~height:350
	   ~poster:"/public/img/2012-04-12-video-poster.png"
	   [ "/public/videos/2012-04-13.mp4", "video/mp4" ;
	     "/public/videos/2012-04-13.ogv", "video/ogg" ])
	(bullets 
	   ~title:"L'outil des associations"
	   ~subtitle:"Découvez la meilleure façon de..."
	   [ "Gérer vos membres, votre annuaire et vos adhésions." ;
	     "Organiser des évènements, des réunions, des assemblées générales." ;
	     "Communiquer plus facilement avec les membres de votre association." ;
		 "Déléguer des responsabilités tout en gardant le contrôle."
		  ]) ;
      
	ribbon ( important
		"« Plus simple et plus puissant !»"
		"« RunOrg remplace ou centralise : les mailing listes, les fichiers Excel, les documents partagés,
les albums photos, les formulaires d’inscription, les newsletters, les sondages, les forums… 
Une seule plateforme pour tout faire : c’est plus simple et plus puissant ! »
Suzel Chassefeire, présidente de la Chambre Des Associations") ;

(*	ribbon 
	  (quote ~who:"Suzel Chassefeire, présidente de la Chambre Des Associations" "RunOrg remplace ou centralise : les mailing listes, les fichiers Excel, les documents partagés,les albums photos, les formulaires d’inscription, les newsletters, les sondages, les forums… Une seule plateforme pour tout faire : c’est plus simple et plus puissant !") ; *)
	     
      composite `LR
	(pride
	   ~title:"Prise en main immédiate"
	   ~subtitle:"Vos membres vont adorer"
	   "L'interface de RunOrg est intuitive, facile à maîtriser et ludique : les membres de votre association l'adopteront rapidement pour communiquer entre eux et avec les responsables de l'association.

Nous le constatons chez tous nos clients : en quelques jours, leur intranet RunOrg devient la façon la plus simple de communiquer et de s'organiser."
	)
	(image "/public/img/2012-08-28-5-cut.png") ;

      composite `LR
	(image "/public/img/2012-08-28-9-cut.png")
	(pride
	   ~title:"Dédié aux associations"
	   ~subtitle:"Nous avons pensé à vous"
	   "Les nouvelles technologies évoluent, pourquoi les entreprises 
et les particuliers seraient-ils les seuls à en profiter ?

Plutôt que de recycler des outils pour entreprises, RunOrg a été conçu dès le départ pour répondre aux besoins spécifiques des associations, de leurs responsables et de leurs membres."
	) ;

      ribbon 
	(important 
	   "Respect de la vie privée"
	   "On dit des réseaux sociaux que si vous n'êtes pas le client, vous êtes le produit. 
Chez RunOrg, les données privées de nos utilisateurs leur appartiennent, 
elles ne seront jamais vendues à des annonceurs ou des entreprises."
	) ;

      composite `LLR
	(pride
	   ~title:"Gratuit, pour toujours"
	   ~subtitle:"Parce que c'est pour la bonne cause"
	   "Nous avons vu trop d'équipes motivées s'épuiser et renoncer 
parce qu'elles n'avaient pas les bons outils.

Organiser un groupe autour d'une passion ou d'un projet, ça ne s'improvise pas. Mais grâce à RunOrg, au moins cela devient gratuit."
	)
	(price
	   "Gratuit"
	   "pour les associations"
	   "de moins de 2000 adhérents") ; 
      
      recommend 
	~title:"Ils recommandent RunOrg"
	~subtitle:"Nous avons changé leur vie"
	[ ( "Frédéric Roualen" ,
	    "Équipe de France féminine de Judo" ,
	    "L’interface de l’outil est agréable et facile à prendre en main. Et en plus c’est ludique ! Mes membres y accèdent même depuis leurs smartphones." ) ;
	  ( "Antoine Pierchon" ,
	    "Président de la Fédé B", 
	    "Grâce à RunOrg j’ai pu récupérer très rapidement les informations des participants, les mini-sondages sont parfaits pour planifier des réunions." ) ;
	  ( "Cédric Esserméant" , 
	    "Président des Centaures de Grenoble" ,
	    "RunOrg me permet de confier l’administration des cours et l’organisation des matchs ! Je peux enfin déléguer en gardant la visibilité dessus." ) 
	] ;
      
      hr () ;
      
      composite `LR 
	(pride 
	   ~title:"Conçu par des experts"
	   ~subtitle:"Des années d'expérience associative"
	   ~link:("http://runorg.com/blog"," Et suivez nos conseils com' sur notre blog !")
	   "La communication dans les associations, c'est compliqué, et on ne sait pas toujours à qui s'adresser. 

	   Notre équipe répond à vos questions ! Devenez fan de notre page Facebook et posez-nous vos questions sur notre mur.")
	   (facebook ()) ;	
    ] ;

  page "/associations/benefits" "RunOrg - Avantages"
    [ composite `LR
	(image "/public/img/2012-04-19-1.png")
	(pride
	   ~title:"Un seul outil pour tous"
	   ~subtitle:"Tout faire depuis un seul outil c'est bien plus simple !"
	   "Pour les responsables comme pour les membres : plus besoin d'apprendre à utiliser un logiciel différent pour gérer le fichier adhérents, partager des photos ou des documents, organiser des événements ou des sondages, etc.

RunOrg regroupe en une seule plate-forme tous ces outils, avec une interface commune. Les membres s'y retrouvent facilement, et les responsables n'ont plus besoin de formations multiples."
	) ;
      
      composite `LR
	(pride
	   ~title:"Une meilleure mobilisation"
	   ~subtitle:"S'impliquer n'a jamais été aussi simple"
	   "Pour les membres, échanger avec son association est difficile : 
on ne sait pas comment, ça ne marche pas, ou ça prend du temps. Alors, souvent, on ne le fait pas, et on ne se sent pas impliqué.  

RunOrg fournit aux membres un outil simple pour communiquer avec leur association et pour s'informer sur les dernières actualités. Et nous avons constaté que les membres s'impliquent et se mobilisent davantage, et plus efficacement. "
	) 
	(image "/public/img/2012-04-19-2.png")
	   ;
      composite `LR
	(image 
	   ~copyright:("http://www.flickr.com/photos/giena/3361653109/",
		       "Eugenijus Barzdzius")
	   "/public/img/imagerugby.jpg")
	(pride
	   ~title:"Plus d'échanges et de cohésion"
	   ~subtitle:"Partager un espace privé, cela soude une communauté"
	   "Plus que les autres, les membres des associations et des clubs ont besoin de se sentir appartenir à une communauté, un groupe, un équipe. Ils veulent pouvoir échanger entre eux et partager passion, conseils ou services.

RunOrg offre aux membres l'espace de communication dont ils ont besoin pour échanger entre eux dans le cadre de l'association. Ces échanges directs sont le moteur de la cohésion au sein des associations et des clubs."
	) ;
      composite `LR

	(pride
	   ~title:"Meilleur partage des tâches"
	   ~subtitle:"Déléguer devient accessible et évident"
	   "Les responsables associatifs le savent bien : le manque de contrôle et l'ampleur des tâches à réaliser sont deux freins important qui les empèchent de déléguer ou de trouver des volontaires.

RunOrg permet de déléguer tout en gardant le contrôle sur ce qui a été fait. De plus l'outil permet de répartir certaines tâches sur les membres (ex : inscriptions en ligne). Les responsables vont adorer leur nouveau temps libre !")
	(image  "/public/img/imagephilippines.jpg")
    ] ;

  page "associations/standard" "RunOrg Associations - Standard"
    [ Catalog.associations_standard_title;     
	Catalog.default_price_asso ;
];

  page "associations/Students" "RunOrg Associations - BDE et Associations Etudiantes"
   [ Catalog.associations_students_title ;
	Catalog.associations_students_desc_a ;
	Catalog.associations_students_desc_b ;
	Catalog.associations_students_desc_c ;
];

  page "associations/Ess" "RunOrg Associations - Economie Sociale et Solidaire"
    [ Catalog.associations_ess_title ;
	Catalog.associations_ess_desc_a ;
	Catalog.associations_ess_desc_b ;
];

  page "associations/Impro" "RunOrg Associations - Théâtre d'Improvisation"
    [ Catalog.associations_impro_title ;
	Catalog.associations_impro_desc_a ;
	Catalog.associations_impro_desc_b ;
];

  page "associations/MultiSports" "RunOrg Associations - Clubs multi-sports "
    [ Catalog.associations_multisports_title ;
	Catalog.associations_multisports_desc_a ;
	Catalog.associations_multisports_desc_b ;
];

  page "associations/Judo" "RunOrg Associations - Judo et Jujitsu"
    [ Catalog.associations_judo_title ;
	Catalog.associations_judo_desc_a ;
	Catalog.associations_judo_desc_b ;
];

  page "associations/Badminton" "RunOrg Associations - Badminton "
    [ Catalog.associations_badminton_title ;
	Catalog.associations_badminton_desc_a ;
	Catalog.associations_badminton_desc_b ;
	Catalog.associations_badminton_desc_c ;
];

  page "associations/Footus" "RunOrg Associations - Football US & cheerleading "
    [ Catalog.associations_footus_title ;
	Catalog.associations_footus_desc_a ;
	Catalog.associations_footus_desc_b ;
];

  page "associations/Athle" "RunOrg Associations - Athlétisme "
    [ Catalog.associations_athle_title ;
	Catalog.associations_athle_desc_a ;
];

  page "associations/SalleSport" "RunOrg Associations - Salle de sport et coaching "
    [ Catalog.associations_sallesport_title;
	Catalog.associations_sallesport_desc_a ;
	Catalog.associations_sallesport_desc_b ;
];

  page "associations/Sports" "RunOrg Associations - Autres sports"
    [ Catalog.associations_sports_title ;
	Catalog.associations_sports_desc_a ;
	Catalog.associations_sports_desc_b ;
	Catalog.associations_sports_desc_c ;
];

  page "associations/Federations" "RunOrg Associations - Fédérations"
    [ Catalog.associations_federations_title ;
	Catalog.associations_federations_desc_a ;
	Catalog.associations_federations_desc_b ;
      hr () ;
       composite `LR
      Catalog. plateforme_complete 
	Catalog.associations_federations_desc_c ;
];


  page "/associations/options" "RunOrg Associations - Options"
    [ offer 
	~title: "Pack Pro"
	~price: "20€/mois"
	"Pour les associations exigentes nous avons créé un pack de services et de fonctionnalités leur permettant de gagner du temps lors de la mise en place de l'outil et de bénéficier d'une assistance prioritaire."
	[ "Assistance+ en ligne : support moins de 24h (jours ouvrés)" ;
	  "Fonctionnalités Pro : administrateurs de groupe, fiches administrateurs sur les membres, [et d'autres à venir]" ;
	  "Offert : 30 minutes de conseils sur l'utilisation de l'outil pour votre collectivité" ] ;

	 offer 
	~title: "Personnalisation+"
	~price: "A partir de 100€/mois"
	"RunOrg s'efface pour vous permettre d'utiliser vos propres logos, nom de domaines et couleurs. Ce mode de fonctionnement en 'marque grise' vous permet d'offrir à vos adhérents et membres le meilleurs de notre technologie sous votre marque !"
	[ "Application personnalisée à vos couleurs" ;
	  "Votre logo même sur les pages personnelles des membres" ;
	  "Votre nom de domaine" ;
	  "C'est le nom de votre association qui apparait dans les envois emails" ] ;

	 offer 
	~title: "Portail Multi-espaces"
	~price: "A partir de 200€/mois"
	"Pour les fédérations ! En plus de s'effacer pour vous permettre d'utiliser vos propres logos, nom de domaines et couleurs, RunOrg vous permet de créer autant d'espace à vos couleurs que vous le souhaitez ! Permet par exemple à une fédération d'offrir un espace indépendant et un site Internet à chacune des associations affiliées, et de bénéficier automatiquement d'un annuaire."
	[ "Inclus : toutes les caractériques de l'option Personnalisation+" ;
	  "Nombre illimité d'espaces" ;
	  "Annuaire de tous les espaces de votre domaine classés par mots clefs" ;
	  "Une page portail donnant l'accès à l'ensemble de vos espaces" ;
	  "D'autres options sont disponibles. Contactez-nous." ] ;
];

  page "/associations/services" "RunOrg Associations - Services"
    [ offer 
	~title: "Assistance+ en ligne"
	~price: "10€/mois"
	"Vous avez des questions et vous souhaitez des réponses rapides ? Avec ce service nous nous engageons à vous répondre dans les 24h ouvrés !"
	[ "Support en ligne moins de 24h" ] ;

	offer 
	~title: "Assistance téléphonique"
	~price: "40€/mois"
	"Si vous recherchez la tranquilité : c'est ce service qu'il faut souscrire ! Si vous avez des questions ou que vous souhaitez des conseils pour utiliser au mieux votre outil : on en parle directement au téléphone. Dans le cadre de ce service, nous pouvons prendre la main dans votre espace pour vous aider à réaliser certaines opérations."
	[ "Envoyez-nous un message : nous vous rappelons" ;
	  "Support téléphonique en moins de 24h (jours ouvrés)";
	  "1h disponible par mois pour du support ou des conseils" ] ;

	offer 
	~title: "Community Management"
	~price: "A partir de 150€/mois"
	"Vous avez une communauté à animer en ligne, mais vous n'êtes pas à l'aise avec les codes et les usages, ou vous craignez que cela vous prenne trop de temps : nous nous en chargeons pour vous ! Nous définissons ensemble le plan de communication le plus adapté à votre communauté et à son public."
	[ "Animation de votre espace" ;
	  "Modalités précises à définir ensemble" ] ;

   offer 
	~title: "Pack de lancement"
	~price: "500 €"
	"Cette offre comprend la prise en main de votre espace, la configuration par nos soins selon vos besoins. Accompagnement dans la communication vers vos membres et leurs inscriptions. Vous disposez ensuite de 2 heures de support téléphonique durant lesquels nous pouvons également intervenir dans votre espace."
	[ "Adaptation de votre espace selon vos besoins" ;
	  "Inscription de vos membres" ;
	  "2 heures d’assistance téléphonique sur le premier mois d’abonnement" ] ;

	offer 
	~title: "Formation"
	~price: "800€/jour"
	"Sur la base d'une formation par demi-journée nous formons les profils administrateurs et/ou les profils membres de vos espaces. Les formations sont adaptées à vos besoins et à votre type d'utilisation de RunOrg."
	[ "Formation profils membres ou administrateurs" ;
	  "Contenu adapté à vos besoins et vos usages" ] ;

	offer 
	~title: "Fonctionnalités sur mesure"
	~price: "Selon les besoins"
	"Vous avez des besoins particuliers pour lesquels il n'existe pas encore de fonctionnalité dans RunOrg ? Contactez-nous pour nous en faire part. Nous sommes en mesure de développer des fonctionnalités adaptées à vos besoins dans le cadre de notre outil. Vous réduisez ainsi les coûts et les risques par rapport au développement d'un outil complet car vous bénéficiez de toutes les fonctionnalités déjà disponibles dans RunOrg."
	[ "Equipe projet dédiée" ;
	  "Conseils techniques et fonctionnels" ;
	  "Développements intégrés dans l'application RunOrg";
	  "Maintenance des développements incluse" ] ;

	offer 
	~title: "Espace disque supplémentaire"
	~price: "2€/Go/mois"
	"Si vous vous sentez à l'étroit dans l'espace que nous vous offrons par défaut : agrandissez-vous !"
	[ "Espace disponible en cloud" ] ;

];


  page "/associations/pricing" "RunOrg - Tarifs Associations"
      [    ribbon 
	(important 
	   "L'offre la plus compétitive du marché !"
	   "Des tarifs adaptés à vos besoins et à votre organisation."
	) ;

	prices [
	  ("GRATUIT",  "free - gratis",[ "2000 personnes"   ; "2 Go"  ],[ ""]) ;
	  ("125", "HT par mois",[ "5000 personnes"  ; "5 Go" ],[ "Assistance+ en ligne" ; "Pack Pro" ]) ;
	  ("200", "HT par mois",[ "10000 personnes" ; "10 Go" ],[ "Pack Pro" ; "Assistance téléphonique" ])	  
	] 

	  "Toutes nos offres incluent l'hébergement, la maintenance et les mises à jour logicielles"
	  "<a href=\"contact\">Contactez-nous</a> si vous souhaitez créer des espaces pour plus de 10000 personnes." 

;

	ribbon_title ~name:"options" "Options disponibles" ;


	option_offer  ~before:"À partir de" ~link:("/associations/options","En savoir plus...") 
	  "100" "HT par mois" "Personnalisation+"
	  "Mettez l'espace de votre association à vos couleurs et sur votre nom de domaine."
	;

	option_offer  ~before:"À partir de" ~link:("/associations/options","En savoir plus...") 
	  "200" "HT par mois" "Portail Multi-espaces"
	  "Inclus l'option personnalisation+, créez autant d'espaces à vos couleurs que vous le souhaitez, disposez d'un portail pour les recencer, permettez à vos clubs et associations affiliés d'en bénéficier."
	;

	option_offer  ~before:"À partir de" ~link:("/associations/services","En savoir plus...") 
	  "150" "HT par mois" "Community Management"
	  "Nous vous proposons de vous aider à animer votre communauté en ligne. Modalités précises à définir ensemble."
	;

	option_offer  ~before:"" ~link:("/associations/services","En savoir plus...") 
	  "40" "HT par mois" "Assistance téléphonique"
	  "Ne cherchez plus : demandez ! 1h d'assistance téléphonique pour vous dépanner ou vous conseiller chaque mois."
	;

	option_offer ~before:"" ~link:("/associations/services","En savoir plus...") 
	  "800" "HT par jour" "Formation"
	  "Pour vous ou vos utilisateurs, nous organisons des formations adaptées à vos besoins et à votre d'utilisation de l'outil.

Un jour de formation est offert avec l'offre à 400€/mois"
	;

	option_offer  ~before:"" ~link:("/associations/services","En savoir plus...") 
	  "500" "HT" "Pack lancement de votre espace"
	  "Configuration de votre espace selon vos besoins, invitation de vos membres et support téléphonique durant le premier mois."
	;

	option_priceless ~link:("/associations/services","En savoir plus...")
	  "Fonctionnalités sur mesure"
	  "Vous avez des besoins particuliers et vous souhaitez que notre outil y répondre ? Rien de plus simple : nous les développons et les intégrons dans votre application !"
	;
    ] ;

  page "/associations/features" "RunOrg Associations - Fonctionnalités"
      [ 
      ribbon 
	(important 
	   "Vos données sont en sécurité"
	   "Par défaut, toutes vos informations privées sont accessibles uniquement aux membres de votre espace.

Vous pouvez choisir de rendre sélectivement publiques certaines de ces informations, 
ou au contraire les rendre accessibles aux membres de certains groupes uniquement."
	) ;


      ribbon_title ~name:"organisationdesmembres" "Organisation des membres et des accès" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-1-cut.png" ;
		       "/public/img/2012-08-28-9-cut.png" ])
	(features [ 
	  "Groupes de membres",
	  "Répartissez vos membres dans des groupes de votre choix (administrateurs, agents, administrés, etc.)" ;
	  
	  "Demandes d'inscription",
	  "Les administrés peuvent demander à s'inscrire aux groupes - sauf aux groupes secrets." ;
	  
	  "Gestion des inscrits",
	  "Vous déterminez pour chaque groupe si les demandes d'inscriptions sont validées manuellement ou automatiquement" ;
	  
	  "Inscriptions multiples",
	  "Comme dans la vie réelle, vos membres peuvent appartenir à plusieurs groupes simultanément" ;
	  
	  "Annuaire à jour",
	  "Visualisez facilement la liste des inscrits d'un groupe et leurs informations." ;
	  
	  "Indépendance des groupes",
	  "Chaque groupe dispose d'un mur, d'une zone d'échange de documents et d'un album photo réservés à ses membres."	
	]) ;
      
      ribbon_title ~name:"organisationdesactivites" "Organisation des activités" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-5-cut.png" ;
		       "/public/img/2012-08-29-4-cut.png" ;
		       "/public/img/2012-08-29-3-cut.png" ])
	(features [ 
	  "Création d'activités",
	  "Votre communauté ne se résume pas qu'à des membres. RunOrg gère également les activités.";
	  
	  "Nombreux modèles disponibles",
	  "Selon votre type d'organisation des modèles adaptés vous sont proposés (réunions, CM, rencontres, événements, etc.)";
	  
	  "Agenda privé",
	  "Chaque membre dispose d'un agenda des activités auxquelles il peut participer";
	  
	  "Invitation par groupes",
	  "Pour n'oublier personne et gagner du temps, invitez directement les membres des groupes de votre choix";
	  
	  "Gestion des participants",
	  "Indiquez pour chaque activité si les demandes d'inscriptions sont validées manuellement ou automatiquement";
	  
	  "Niveau de visibilité des activités",
	  "Déterminez si une activité n'est visible qu'aux inscrits, à tous les membres, ou si elle est publiée sur votre site Internet";
	  
	  "Discussions dans les activités",
	  "Chaque activité permet les discussions (mur), la consultation (sondage) et le partage (photos et documents)";
	  
	  "Brouillons",
	  "Prenez votre temps pour créer une activité avant de la publier"	
	]) ;  
  
      ribbon_title ~name:"espacedepartage" "Espace de partage" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-2-cut.png" ])
	(features [ 
	  "Partagez vos documents",
	  "Vos membres et vous même pouvez mettre en ligne et télécharger des documents quel que soit leur format";
	  
	  "Partagez vos albums photo",
	  "Vos membres et vous même pouvez publier et visionner des albums photo";
	  
	  "Définissez qui voit quoi",
	  "Au sein de votre espace vous définissez de manière sélective qui accède à vos photos et vos documents"	
	]) ;
   
  
      ribbon_title ~name:"messagescommunication" "Messages et communication" ; 
      composite `LR 
	(screenshots [ "/public/img/2012-08-28-5-cut.png" ])
	(features [ 
	  "Murs de discussions",
	  "Les communications se font via des murs liés à vos groupes, vos activités ou à des forums";
	  
	  "Listes de diffusion",
	  "Les messages publiés sur les murs ne sont visibles qu'aux membres des groupes concernés";

	  "Emails ciblés",
	  "Les administrateurs peuvent envoyer des messages par emails aux membres des groupes via les murs de discussions.";
	  
	  "Notifications",
	  "Les membres peuvent paramétrer la fréquence des notifications qu'ils reçoivent.";
	  
	  "Réponses aux messages",
	  "Chaque message constitue un flux de discussion indépendant, dont seuls les participants reçoivent des notifications"	
	]) ;   

      ribbon_title ~name:"consultationdesmembres" "Consultation des membres" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-28-7-cut.png" ])
	(features [ 
	  "Création de mini-sondages",
	  "Sur les murs, posez des questions à choix simple ou multiple, par exemple pour choisir une date de réunion";
	  
	  "Réponses aux invitations",
	  "Lorsque vous invitez des membres à participer à des activités ils vous indiquent s'ils viendront ou non.";
	  
	  "Formulaires d'inscription",
	  "Sur les groupes et les activités, vous pouvez demander aux inscrits de fournir des informations obligatoires";	  
	]) ;
    
      
      ribbon_title ~name:"forumsdiscussions" "Forums et discussions" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-10-cut.png" ])
	(features [ 
	  "Forums de discussion",
	  "Un forum permet la discussion (mur), la consultation (sondage) et le partage (photos, documents) autour d'un thème";
	  
	  "Forums publics",
	  "Tous les membres peuvent voir et participer aux forums publics de votre espace";
	  
	  "Forums privés",
	  "Seuls les inscrits peuvent voir les forums privés, vous avez le contrôle sur les inscriptions";
	  
	  "Forums de groupes",
	  "Les groupes peuvent disposer de forums privés réservés à leurs membres"	
	]) ;   

      ribbon_title ~name:"priseenmainrapide" "Prise en main rapide" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-7-cut.png" ;
		       "/public/img/2012-08-28-8-cut.png" ])
	(features [ 
	  "Espace pré-adapté à vos besoins",
	  "Chaque espace est livré avec des groupes, formulaires et modèles qui sont utiles à votre type de besoin.";
	  
	  "Import des membres",
	  "Utilisez un tableur ou votre carnet d'adresses pour importer vos membres avec un simple copier/coller";
	  
	  "Rien à installer",
	  "RunOrg est entièrement en ligne : tous vos membres peuvent l'utiliser sans rien installer sur leurs postes.";
	  
	  "Ergonomique et simple",
	  "Peut être utilisé sans formation, et avec plaisir !";
	  
	  "Connexions en un clic",
	  "Lorsque vous recevez une notification, cliquez sur le lien pour vous connecter à votre espace et au bon endroit.";
	  
	  "Transition en douceur",
	  "Les membres que vous avez inscrits et qui n'ont pas encore rejoint RunOrg reçoivent tous vos messages par mail."	
	]) ;   

      ribbon_title ~name:"personnalisationintranet" "Personnalisation de votre intranet" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-6-cut.png" ])
	(features [ 
	  "Créez le miroir virtuel de votre organisation réelle",
	  "Vous êtes déjà organisés autour de groupes, de projets ou d'activités ? Créez dans votre espace la même organisation.";
	  
	  "Créez vos propres formulaires",
	  "Créez vos propres formulaire d'accès ou de participation à un groupe ou une activité";
	  
	  "Personnalisez vos tableaux",
	  "Les administrateurs peuvent ajouter des colonnes aux listes d'inscrits des activités et des groupes.";
	  
	  "Logos et images",
	  "Insérez votre logo et définissez des images pour vos différents évènements"	
	]) ;
     
      ribbon_title ~name:"espacepriveconfidentialite" "Espace privé et confidentialité" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-8-cut.png" ;
		       "/public/img/2012-08-29-12-cut.png" ])
	(features [ 
	  "Connexion sécurisée",
	  "Tous les accès à RunOrg se font de façon cryptée et sécurisée";
	  
	  "Accès nominatifs et contrôlés",
	  "Chaque personne dispose d'un compte pour lequel nous avons vérifié la validité de l'adresse email";
	  
	  "Niveaux de visibilité",
	  "Chaque groupe ou activité peut être visible sur internet, par tous les membres, ou seulement par les invités.";
	  
	  "Vous avez le contrôle total",
	  "Les administrateurs de votre association définissent les accès à votre espace, et qui peut voir ou participer à vos activités";
	  
	  "Vie privée respectée",
	  "Les informations de votre espace privé sont inaccessibles aux moteurs de recherche et ne sont pas revendues à des tiers";
	  
	  "Gestion des informations personnelles",
	  "Chaque membre contrôle et peut modifier les informations personnelles qu'il partage avec ses organisations"	
	]) ;

      ribbon_title ~name:"profilsmembres" "Profils membres" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-28-1-cut.png" ])
	(features [ 
	  "Informations personnelles",
	  "Retrouvez les coordonnées et les informations personnelles de chaque membre sur sa page de profil";
	  
	  "Fiches d'information",
	  "Associez des remarques ou des fiches d'informations au profil d'un membre";
	  
	  "Liste des groupes",
	  "En un coup d'oeil, visualisez dans quels groupes est inscrit un membre";
	  
	  "Restrictions d'accès",
	  "Seuls les administrateurs ont accès aux données personnelles des membres";
	  
	  "Historique des publications",
	  "Le profil contient la liste des messages, photos et fichiers mis en ligne par le membre"	
	]) ;
    
  
      ribbon_title ~name:"administration" "Administration" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-29-9-cut.png" ;
		       "/public/img/2012-08-29-11-cut.png"])
	(features [ 
	  "Administrateurs globaux",
	  "En tant qu'administrateur de votre espace privé vous pouvez tout voir et tout faire";
	  
	  "Délégation de l'administration",
	  "Nommez des personnes responsables de votre espace, ou d'une activité en particulier.";
	  
	  "Modération",
	  "Les administrateurs peuvent modérer les messages, les photos et les documents";
	  
	  "Publication d'articles sur Internet",
	  "Seuls les administrateurs peuvent publier des articles sur votre site Internet";
	  
	  "Export des listes",
	  "Les administrateurs peuvent exporter dans un tableur la liste des inscrits à un groupe ou une activité"	
	]) ;

      ribbon_title ~name:"website" "Site Internet" ;
      composite `LR 
	(screenshots [ "/public/img/2012-08-28-2-cut.png" ;
		       "/public/img/2012-08-28-3-cut.png"])
	(features [ 
	  "Publication d'articles",
	  "Vous publiez vos annonces à la manière d'un blog et tout aussi facilement";
	  
	  "Abonnement aux articles",
	  "Les internautes peuvent recevoir par mail les annonces que vous publiez";
	  
	  "Agenda en ligne",
	  "Mettez facilement en ligne les évènements que vous voulez rendre publics";
	  
	  "Inscriptions et adhésions en ligne",
	  "Les internautes peuvent demander à s'inscrire à votre espace ou à participer à vos activités en ligne";
	  
	  "Page de présentation",
	  "Une page de présentation publique vous permet de présenter votre collectivité, de renseigner son logo et ses coordonnées";
	  
	  "Hébergement gratuit",
	  "Nous assurons gratuitement l'installation, l'hébergement et la maintenance de votre site internet"	
	]) ;   

    ] ;


  (* END PAGES -------------------------------------------------------------- *)
] 
