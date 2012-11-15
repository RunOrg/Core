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
	   ~subtitle:"Toute la communication numérique depuis un même espace"
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
	    "Présidente Ile De France News", 
	    "Grâce au portail abonnés de RunOrg je peux intéragir avec mes abonnés, leur offrir de nouveaux services et augmenter mon audience." ) ;
	  ( "Laurent Villemur" , 
	    "Directeur de ActeIII formation" ,
	    "La mise en place rapide et facile de RunOrg nous a permis de répondre aux besoins de nos stagiaires qui souhaitaient rester en lien après les formations." ) 
	] ;
 ];

  page "/entreprises/Company" "RunOrg Entreprises"
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

  page "/entreprises/CompanyTraining" "RunOrg Entreprises - Centres de formation"
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

  page "/entreprises/pricing" "RunOrg - Tarifs Entreprises"
      [ pricing 
	~foot:"Prix exprimés hors taxes. Consultez nos <a href=\"/autres/accompagnement\">offres d'accompagnement</a> et <a href=\"/contact\">contactez-nous</a> pour toutes informations supplémentaires."
	 [ "Petit espace" ]; 
	  [  "Espace moyen"] ;
	  [  "Gros espace" ];
	   [ "Très gros espace" ] 
	[ "Prix", [ `Text "10€/mois" ; 
		    `Text "100€/mois" ;
		    `Text "200€/mois" ;
		    `Link ("/contact", "Nous Contacter") ];
	  "Accès inclus", [ `Text "500" ;
			    `Text "5000" ;
			    `Text "10000" ;
			    `Text "+ de 10000" ];
	  "Option personnalisation+", [ `Text "100€/mois" ;
				`Text "100€/mois" ;
				`Tick ;
				`Tick ];
	  "Option Multi-portails", [ `NoTick ;
				`Text "100€/mois" ;
				`Text "100€/mois" ;
				`Text "100€/mois" ];				
	  "Espace disque", [ `Text "4 Go" ;
			     `Text "5 Go" ;
			     `Text "5 Go" ;
			     `Text "10 Go" ;
			     `Text "10 Go" ] ;
	  "Hébergement et mises à jour", [ `Tick ; 
					   `Tick ;
					   `Tick ; 
					   `Tick ; 
					   `Tick ] ;
	  "Assistance premium", [ `Text "95€/an" ;
				`Text "95€/an" ;
				`Tick ;
				`Tick ;
				`Text "95€/an" ] ;
	  "Formation initiale", [ `NoTick ;
				       `NoTick ; 
				       `Text "2 heures" ;
				       `Text "2 heures" ;
				       `NoTick ] ;
	  "Assistance téléphonique", [ `NoTick ;
					    `NoTick ;
					    `Text "2 heures" ;
					    `Text "2 heures" ;
					    `NoTick ] ;
	  "100 accès suppl.", [ `Link ("/contact", "Nous Contacter") ;
					 `Text "70€/an" ;
					 `Text "20€/an" ;
					 `Text "20€/an"  ;
					 `Text "800€/an" ] ;
	  "Espace disque suppl.", [ `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ;
				    `Text "2€/Go/mois" ] 
	] ;
    ] ;
	       
  (* END PAGES -------------------------------------------------------------- *)
] 
