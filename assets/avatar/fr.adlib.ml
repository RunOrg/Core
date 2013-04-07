| `Anonymous -> "Anonyme"
| `Avatar_Directory_Empty -> "Il n'y a personne ici !"

| `Avatar_Notify_Mail (sentence, action) -> begin 
  match action with 
    | `Member -> begin
      match sentence with 
	| `Title asso -> !! "Invitation - %s" asso
	| `Action     -> "vous invite à un espace en ligne"
	| `Body asso  -> !! "%s utilise l'outil en ligne RunOrg pour la gestion de ses membres, activités et évènements. Pour répondre aux messages, visualiser les photos, participer aux évènements et aux sondages, créez votre compte en cliquant sur le bouton ci-dessous :" asso
	| `Button     -> "Connexion"
    end 
    | `Admin -> begin
      match sentence with 
	| `Title asso -> !! "Droits d'administration - %s" asso
	| `Action     -> "vous confie les pleins pouvoirs d'administration"
	| `Body asso  -> !! "%s utilise l'outil en ligne RunOrg pour la gestion de ses membres, activités et évènements. Pour découvrir les fonctionnalités et les pouvoirs réservés aux administrateurs (création de groupes et d'activités, visibilité totale et modération), cliquez sur le bouton ci-dessous :" asso
	| `Button     -> "Connexion"
    end 
end
