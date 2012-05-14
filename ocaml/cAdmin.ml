(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Include = struct
  open CAdmin_i18n
  open CAdmin_news
  open CAdmin_client
  open CAdmin_preConfig
  open CAdmin_payment
  open CAdmin_fullStats
  open CAdmin_page
  open CAdmin_obliterate
  open CAdmin_make
  open CAdmin_user
  open CAdmin_confirm
  open CAdmin_order
  open CAdmin_newInstance
  open CAdmin_network
  open CAdmin_rss
  open CAdmin_extract
end
  
module CStats = struct

  let () = CAdmin_common.register UrlAdmin.news_stats begin fun i18n user req res -> 

    let csv_head = [
      "Date" ;
      "Instances (30j)" ;
      "Instances (7j)" ;
      "Instances" ;
      "Utilisateurs (30j)" ;
      "Utilisateurs (7j)" ;
      "Utilisateurs" ;
      "Connexions (30j)" ;
      "Connexions (7j)" ;
      "Connexions" ;
      "Messages (30j)" ;
      "Messages (7j)" ;
      "Messages"
    ] in
    
    let csv_of_stats (date,t) = 
      (BatOption.default "" $ MFmt.format_date `Fr date) 
      :: List.map string_of_int [ 
	t # active_instances_30 ;
	t # active_instances_7  ;
	t # active_instances    ;
	t # active_users_30 ;
	t # active_users_7  ;
	t # active_users    ;
	t # logins_30 ;
	t # logins_7  ;
	t # logins    ;
	t # messages_30 ;
	t # messages_7  ;
	t # messages    ;
      ] 
    in

    let! list = ohm $ MNewsStats.extract () in
    
    return $ Action.file ~file:"stats.csv" ~mime:"text/csv"
      ~data:(OhmCsv.to_csv csv_head (List.map csv_of_stats list)) res
    
  end 

  let () = CAdmin_common.register UrlAdmin.stats begin fun i18n user request response ->

    let td s x = "<td style='" ^ s ^ "'>" ^ x ^ "</td>" in
    let tr x = "<tr>" ^ x ^ "</tr>" in
    let table x = "<table style='margin:auto'>" ^ x ^ "</table>" in

    let row (t,i) =
      i |> Run.map begin fun i -> 
	[ td "text-align:right;font-size:16px" (string_of_int i) ; td "" t ] 
	|> String.concat ""
      end 
    in

    let entity_stats = MEntity.Backdoor.count |> Run.memo in
    let entity x = entity_stats |>
	Run.map (fun stats -> try List.assoc x stats with Not_found -> 0) in

    let relinst_count = Run.memo MRelatedInstance.Backdoor.count in 
    let digestsbs_count = Run.memo MDigest.Subscription.Backdoor.count in

    let stats = [
      "Associations" , MInstance.Backdoor.count () ;
      "Profils"      , MInstance.Profile.Backdoor.count () ;
      "Comptes confirmés" , MUser.Backdoor.count_confirmed ;
      "Utilisateurs"     , MUser.Backdoor.count_undeleted ;
      "Evènements"   , entity `Event ;
      "Adhésions"    , entity `Subscription ;
      "Sondages"     , entity `Poll ;
      "Forums"       , entity `Forum ;
      "Groupes"      , entity `Group ;
      "Messages"     , MItem.Backdoor.count () ;
      "Commentaires" , MComment.Backdoor.count ;
      "Favoris"      , MLike.Backdoor.count () ;
      "Fiches"       , MMembership.Backdoor.count () ;
      "Contacts Réussis", relinst_count |> Run.map (#bound) ;
      "Contacts en Attente", relinst_count |> Run.map (#unbound) ;
      "Broadcasts"   , MBroadcast.Backdoor.posts ;
      "Forwards"     , MBroadcast.Backdoor.forwards ;
      "Direct DigestSbs", digestsbs_count |> Run.map (#direct) ;
      "Member DigestSbs", digestsbs_count |> Run.map (#member) ;
      "Network DigestSbs", digestsbs_count |> Run.map (#through) ;
      "Blocked DigestSbs", digestsbs_count |> Run.map (#blocked) 
    ] in

    let title = return (View.esc "Statistiques") in

    let body = 
      Run.list_map row stats
      |> Run.map (List.map tr)
      |> Run.map (String.concat "")
      |> Run.map table
      |> Run.map View.str      
    in

    CCore.render ~title ~body response

  end

end

module ErrorAudit = struct

  module Data = Fmt.Make(struct
    module IUser = IUser
    type json t = <
      server : string ;
      url    : string ;
      exn    : string ;
      admin  : IUser.t 
    > 
  end)

  let send_error_mail =
    let task = Task.register "adminNotify.error" Data.fmt begin fun args _ ->
      MMail.send_to_self (args # admin)
	begin fun _ _ send ->
	  send
	    ~subject:(View.str ("[ERREUR] " ^ args # url))
	    ~text:(fun ctx -> ctx
	      |> View.str "Bonjour, Maître\n\n"
	      |> View.str "L'erreur suivante s'est produite: \n\n"
	      |> View.str ("  "^args#server^"\n\n")
	      |> View.str ("  "^args#url^"\n\n")
	      |> View.str ("  "^args#exn^"\n\n"))
	    ~html:None	  
	end 
      |> Run.map (fun success -> if success then Task.Finished args else Task.Failed)
    end in 
    MModel.Task.call task

  let _ = 
    let! error = Sig.listen MErrorAudit.Signals.on_create in
    MAdmin.map begin fun admin -> 
      send_error_mail (object
	method server = error # server
	method url    = error # url
	method exn    = error # exn
	method admin  = IUser.Deduce.is_self admin |> IUser.decay
      end)
    end
    |> Run.list_map identity |> Run.map ignore

end

