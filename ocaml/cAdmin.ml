(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents
module Active  = CAdmin_active
module Public  = CAdmin_public

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
    
  ] in
  
  page cuid "Administration" (object
    method parents = [] 
    method here  = Parents.home # title 
    method body  = choices
  end) res

end
