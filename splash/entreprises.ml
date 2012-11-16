open Common
open WithSections 

let page url title list =
  let url = "/entreprises"^url in
  page url title 
    ~section:"entreprises"
    ~head:"entreprises" 
    ~subsection:url 
    list

(* Gestion des photos
Pour uniformiser la taille des images
exporter depuis flickr en 500x333
paint : réduir à 93%
puis découper à : 465x270 *)
	
let pages = [
  (* BEGIN PAGES ------------------------------------------------------------ *)

 page "" "RunOrg Entreprises"
 [   composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/proimos/4045973322/",
		       "Alex E. Proimos")
	   "/public/img/preconf_company.jpg")
	(features [ 
	  "Vous restez maître de vos données",
	  "Contrairement à un réseaux social classique, vous êtes propriétaires de vos données et pouvez les télécharger" ;
	    
	  "Simple et rapide à mettre en oeuvre",
	  "L'outil s'adapte et se personnalise en quelques cliques, vous pouvez le faire évoluer selon vos besoins" ;
	  
	  "Faites des économies",
	  "Nos solutions vous font gagner du temps et économiser sur vos relations clients"	
	  
	]) ; 

	ribbon ( important
		"Un outil innovant au service de vos idées"
		"RunOrg offre des espaces communautaires privés aux entreprises leurs permettant d'être plus efficaces et d'innover dans leurs relations avec leurs clients, salariés, fournisseurs, abonnés, partenaires, etc.") ;

      composite `LR
	(pride
	   ~title:"Prise en main immédiate"
	   ~subtitle:"Vos clients et salariés vont adorer"
	   "L'interface de RunOrg est intuitive, facile à maîtriser et ludique : les clients et les salariés  l'adopteront rapidement pour communiquer entre eux et avec vous.

Nous le constatons chez tous nos clients : en quelques jours, leur intranet RunOrg devient la façon la plus simple de communiquer et de s'organiser."
	)
	(image "/public/img/2012-08-28-5-cut.png") ;

      hr () ;

      composite `LR
       (bullets
	   ~title:"La plateforme la plus complète"
	   ~subtitle:"Toute votre communication numérique"
	   ~ordered:false
	   [ "Communication interne via l'espace membre" ;
	     "Communication externe via le site Internet" ;
	     "Outils de gestion et d'organisation collaboratifs" ;
	     "Hébergement, mises à jour et maintenance informatique" ]
	) 	

        (pride
	   ~title:"La technologie accessible"
	   ~subtitle:"L'offre la plus économique du marché"
	   "Nous vous offrons un outil à la pointe, adaptable et évolutif. 
	   
	   Opter pour une solution déjà existante et en ligne est un choix économiquement plus judicieux et plus sûr que de développer ou faire développer sa solution. 
	   
	   Vous êtes dès maintenant en mesure d'évaluer la qualité de l'outil et notre offre tarifaire claire vous permet de connaître précisément les coûts annuels, sans surprise. "
	) ;

      recommend 
	~title:"Ils recommandent RunOrg"
	~subtitle:""
	[ ( "Emir Deniz" ,
	    "Directeur Institut Européen des Politiques Publiques" ,
	    "RunOrg nous permet de garder le lien avec les stagiaires que nous formons ce qui augmente leur taux de retour dans nos formations." ) ;
	  ( "Virginie Do Carmo" ,
	    "Editrice et fondatrice Ile De France News", 
	    "Grâce au portail abonnés de RunOrg je peux intéragir avec mes abonnés, leur offrir de nouveaux services et augmenter mon audience." ) ;
	  ( "Laurent Villemur" , 
	    "Directeur de Acte-trois formation" ,
	    "La mise en place rapide et facile de RunOrg nous a permis de répondre aux besoins de nos stagiaires qui souhaitaient rester en lien après les formations." ) 
	] ;
 ];

  page "/Company" "RunOrg Entreprises"
    [ composite `LR
	(pride ~title:"Entreprises" "Solution simple et flexible à la manière d'un Réseau Social d'Entreprise")
	(create "Company")  ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/proimos/4045973322/",
		       "Alex E. Proimos")
	   "/public/img/preconf_company.jpg")
	(features [ 
	  "Points forts",
	  "Un réseau privé complet, fexible, simple à prendre en main et sans maintenance informatique" ;
	    
	  "Idéal pour...",
	  "Mettre en place des groupes de traivail autour des services existants ou des projets transversaux" ;
	  
	  "Egalement pensé pour...",
	  "Communiquer vers les clients et les fournisseurs"	
	  
	]) ; 
	
	(pride 
	   ~title:"Plus fexible qu'un RSE !"
	   "La solution RunOrg pour les entreprises offre toutes les fonctionnalités d'un intranet d'entreprise, et y ajoute les avantages des outils de travail collaboratif et des réseaux sociaux d’entreprises.

La communication interne de l'entreprise est structurée autour de ses équipes, de ses services et de ses projets. Il est simple et rapide de créer un espace d'échange regroupant les conversations et la documentation et d'y inviter les personnes concernées par le sujet. Vous pouvez déléguer l'administration des différents nœuds d'échange.

A la manière des réseaux sociaux vous disposez d'un annuaire, d'agenda, d'évènements, de documents partagés, de forum et d'albums. Vous organisez des sondages, créer des fiches personnalisés sur les compétences de vos salariés, et disposez d'un outil de statiques intégré.

Vous avez également la possiblité d'ouvrir votre outil à vos clients privilégiés ou vos prestataire pour en faire le portail de votre entreprise."
	) ; 
];

  page "/CompanyTraining" "RunOrg Entreprises - Centres de formation"
    [ composite `LR
	(pride ~title:"Centres de formation" "Solution idéale pour organiser les échanges entre les stagiaires et garder le contact avec eux une fois la formation terminée")
	(create "CompanyTraining")  ;

    composite `LR 
	(image 
	   ~copyright:("http://www.flickr.com/photos/76029035@N02/6829406809/",
		       "Victor1558")
	   "/public/img/preconf_companytraining.jpg")
	(features [ 
	  "Point fort",
	  "Animation du réseaux des formateurs et des stagiaires" ;
	    
	  "Idéal pour...",
	  "Offrir des espaces privés d'échange durant et après la formation" ;
	  
	  "Egalement pensé pour...",
	  "Organiser les activités du centre et communiquer au-près des salariés et des formateurs"	
	  
	]) ; 
	
	(pride 
	   ~title:"Animer votre réseaux de stagiaires"
	   "La solution RunOrg pour les entreprises et les centres de formation offre toutes les fonctionnalités d'un réseau social d’entreprise, et y ajoute les accès et la gestion des formateurs et des stagiaires.

L'entreprise dispose d'outils puissants pour sa communication interne, et offre des espaces séparés et privés pour la communication avec ses formateurs, et entre ses formateurs et leurs stagiaires. Elle anime ainsi un réseau privé de formateurs et de clients.

A la manière des réseaux sociaux vous disposez d'un annuaire, d'agenda, d'évènements, de documents partagés, de forum et d'albums. Vous organisez des sondages, créer des fiches personnalisés sur les compétences de vos stagiaires, et disposez d'un outil de statiques intégré. Chacun des groupes ou des cours peut être indépendant et caché des autres. 
"
	) ; 
];

  page "/PortailAbonnes" "RunOrg Entreprises - Portail Abonnés"
    [ composite `LR
	(pride ~title:"Portail abonnés" "Solution idéale pour fidéliser les abonnés, leurs offrir de nouveaux services, intéragir avec eux, et créer une communauté autour de votre journal")
		(pride 
	   ~title:"Prototype en cours"
	   ~subtitle:"Cette solution est en cours de conception"
	   ~link:("/contact",
		  "Contactez-nous pour en savoir plus") 
	   "Cette solution est en cours de développement ou de prototypage. Si vous le souhaitez, contactez-nous pour participer à sa conception."
	)   ;
];

  page "/PortailClients" "RunOrg Entreprises - Portail Clients"
    [ composite `LR
	(pride ~title:"Portail clients" "Solution idéale pour fidéliser les clients, leur mettre à disposition des ressources et leurs offrir de nouveaux services.")
		(pride 
	   ~title:"Prototype en cours"
	   ~subtitle:"Cette solution est en cours de conception"
	   ~link:("/contact",
		  "Contactez-nous pour en savoir plus") 
	   "Cette solution est en cours de développement ou de prototypage. Si vous le souhaitez, contactez-nous pour participer à sa conception."
	)   ;
];


  page "/pricing" "RunOrg - Tarifs Entreprises"
      [ pricing 
	~foot:"Prix exprimés hors taxes. <a href=\"/contact\">Contactez-nous</a> pour toutes informations supplémentaires."
	[ ["/entreprises/pricing", "Petit espace" ]; 
	  [ "/entreprises/pricing","Espace moyen"] ;
	  ["/entreprises/pricing","Gros espace"] ;
	  ["/entreprises/pricing", "Très gros espace"] ] 
	[ "Prix", [ `Text "10€/mois" ; 
		    `Text "100€/mois" ;
		    `Text "200€/mois" ;
		    `Link ("/contact", "Nous Contacter") ];
	  "Accès inclus", [ `Text "500" ;
			    `Text "5000" ;
			    `Text "10000" ;
			    `Text "+ de 10000" ];
	  "Option Pack Pro", 	[ `Tick ; 
				`Tick ;
				`Tick ; 
				`Tick ] ;
	  "Option personnalisation+", [ `Text "100€/mois" ;
				`Text "100€/mois" ;
				`Tick ;
				`Tick ];
	  "Option Multi-portails", [ `NoTick ;
				`NoTick ;
				`Text "100€/mois" ;
				`Text "100€/mois" ];				
	  "Espace disque", [ `Text "2 Go" ;
			     `Text "10 Go" ;
			     `Text "20 Go" ;
			     `Text "30 Go" ];
	  "Hébergement et mises à jour", [ `Tick ; 
					   `Tick ;
					   `Tick ; 
					   `Tick ] ;
	  "Assistance premium", [ `Text "10€/mois" ;
				`Tick ;
				`Tick ;
				`Tick ] ;
	  "Formation initiale", [ `NoTick ;
				       `NoTick ; 
				       `Text "2 heures" ;
				       `Text "2 heures" ] ;
	  "Assistance téléphonique", [ `NoTick ;
					    `NoTick ;
					    `Text "2 heures" ;
					    `Text "2 heures"] ;
	  "Espace disque suppl.", [ `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ] 
	] ;
	  ribbon_title ~name:"tarifsoptionsentreprises" "Tarif des options" ;

	pricing 
	~foot:"Prix exprimés hors taxes. <a href=\"/contact\">Contactez-nous</a> pour toutes informations supplémentaires."
	[ ["/entreprises/pricing", "Option Pack Pro" ]; 
	  [ "/entreprises/pricing","Option personnalisation+"] ;
	  ["/entreprises/pricing","Option Multi-portails"] ] 
	[ "Prix", [ `Text "10€/mois" ; 
		    `Text "100€/mois" ;
		    `Text "200€/mois" ;
		    `Link ("/contact", "Nous Contacter") ];
	  "Accès inclus", [ `Text "500" ;
			    `Text "5000" ;
			    `Text "10000" ;
			    `Text "+ de 10000" ];
	  "Option Pack Pro", 	[ `Tick ; 
				`Tick ;
				`Tick ; 
				`Tick ] ;
	  "Option personnalisation+", [ `Text "100€/mois" ;
				`Text "100€/mois" ;
				`Tick ;
				`Tick ];
	  "Option Multi-portails", [ `NoTick ;
				`NoTick ;
				`Text "100€/mois" ;
				`Text "100€/mois" ];				
	  "Espace disque", [ `Text "2 Go" ;
			     `Text "10 Go" ;
			     `Text "20 Go" ;
			     `Text "30 Go" ];
	  "Hébergement et mises à jour", [ `Tick ; 
					   `Tick ;
					   `Tick ; 
					   `Tick ] ;
	  "Assistance premium", [ `Text "10€/mois" ;
				`Tick ;
				`Tick ;
				`Tick ] ;
	  "Formation initiale", [ `NoTick ;
				       `NoTick ; 
				       `Text "2 heures" ;
				       `Text "2 heures" ] ;
	  "Assistance téléphonique", [ `NoTick ;
					    `NoTick ;
					    `Text "2 heures" ;
					    `Text "2 heures"] ;
	  "Espace disque suppl.", [ `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ] 
	] ;

    ] ;

  page "/features" "RunOrg Entreprises - Fonctionnalités"
     [ 
      ribbon 
	(important 
	   "Vos données sont en sécurité"
	   "Par défaut, toutes vos informations privées sont accessibles uniquement aux membres de votre espace.

Vous pouvez choisir de rendre sélectivement publiques certaines de ces informations, 
ou au contraire les rendre accessibles aux membres de certains groupes uniquement."
	) ;


      ribbon_title ~name:"organisationdesmembres" "Organisation des membres" ;
      composite `LR 
	(screenshots [ (*"/public/img/2012-08-29-1-cut.png" ;
		       "/public/img/2012-08-28-9-cut.png" *)])
	(features [ 
	  "Groupes de membres",
	  "Répartissez vos membres dans des groupes de votre choix (administrateurs, entraîneurs, sportifs, etc.)" ;
	  
	  "Demandes d'inscription",
	  "Les membres peuvent demander à s'inscrire aux groupes - sauf aux groupes secrets." ;
	  
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
	  "Votre association ne se résume pas qu'à des membres. RunOrg gère également les activités.";
	  
	  "Nombreux modèles disponibles",
	  "Selon votre type d'association des modèles adaptés vous sont proposés (réunions, cours, compétitions, pétitions, etc.)";
	  
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
	  "Les messages publiés sur les murs sont envoyés en totalité par email aux destinataires concernés";
	  
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
	  "Chaque espace est livré avec des groupes, formulaires et modèles qui sont utiles à votre type d'association";
	  
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
	  "Créez vos propres formulaire d'adhésion ou de participation à un groupe ou une activité";
	  
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
	  "Chaque membre contrôle et peut modifier les informations personnelles qu'il partage avec ses associations"	
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
	  "Les internautes peuvent demander à adhérer ou à participer à vos activités en ligne";
	  
	  "Page de présentation",
	  "Une page de présentation publique vous permet de présenter votre association, de renseigner son logo et ses coordonnées";
	  
	  "Hébergement gratuit",
	  "Nous assurons gratuitement l'installation, l'hébergement et la maintenance de votre site internet"	
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
    ] ;


  (* END PAGES -------------------------------------------------------------- *)
] 
