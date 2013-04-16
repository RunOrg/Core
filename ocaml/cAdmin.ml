(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Stats    = CAdmin_stats
module Parents  = CAdmin_parents
module Active   = CAdmin_active
module Public   = CAdmin_public
module Instance = CAdmin_instance
module API      = CAdmin_API
module Unsbs    = CAdmin_unsbs

let () = UrlAdmin.def_home $ admin_only begin fun cuid req res -> 

  let choices = Asset_Admin_Choice.render [
    
    (object
      method img      = VIcon.Large.award_star_gold_1
      method url      = Parents.active # url 
      method title    = return "Instances actives"
      method subtitle = Some (return "Celles qui ont publié le plus d'items chaque mois")
     end) ;

    (object
      method img      = VIcon.Large.world_link
      method url      = Parents.public # url 
      method title    = return "Sites web actifs"
      method subtitle = Some (return "Ceux qui ont publié le plus d'annonces chaque mois")
     end) ;

    (object
      method img      = VIcon.Large.chart_bar
      method url      = Parents.stats # url 
      method title    = return "Statistiques"
      method subtitle = Some (return "Données quotidiennes sur l'utilisation de RunOrg") 
     end) ;

    (object
      method img      = VIcon.Large.database_lightning
      method url      = Parents.api # url 
      method title    = return "API Administrateur"
      method subtitle = Some (return "Traitement de masse sur des données") 
     end) ;

    (object
      method img      = VIcon.Large.user_delete
      method url      = Parents.unsbs # url 
      method title    = return "Désinscriptions"
      method subtitle = Some (return "Utilisateurs qui ont supprimé leur compte RunOrg")
     end) ;

  ] in
  
  page cuid "Administration" (object
    method parents = [] 
    method here  = Parents.home # title 
    method body  = choices
  end) res

end
