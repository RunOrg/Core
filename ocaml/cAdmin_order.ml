(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = Fmt.Make(struct
  type json t = <
    who   : string ;
    email : string ;
    key   : string ;
    total : int ;
    refer : string ;
    main  : string ;
    disk  : string ; 
    paid  : bool ;
    admin : IUser.t 
  > 
end)
  
let send_order_mail =
  let task = Task.register "adminNotify.order" Data.fmt begin fun args _ ->
    let! success = ohm $ MMail.send_to_self (args # admin)
      begin fun _ _ send ->
	send
	  ~subject:(View.str ("[ADMIN] Commande : " ^ args # key ^ ".runorg.com"))
	  ~text:(fun ctx -> List.fold_left (fun ctx str -> View.str str ctx) ctx [
	    
	    "Bonjour, visage pâle,\n\n" ;

	    "Ce client a enregistré une commande de " ;
	    Printf.sprintf "%.2f" (float_of_int (args # total) /. 100.) ;
	    " EUR\n\n" ;

	    "La commande a été créée par " ; args # who ; " (" ; args # email ; ")\n\n" ;

	    (if args # paid then "ELLE A ÉTÉ PAYÉE\n\n" else "") ;

	    "Référence: " ; args # refer ; "\n" ;
	    "Offre principale: " ; args # main ; "\n" ;
	    "Option espace: " ; args # disk ; "\n\n" ;

	    "Hugh, j'ai parlé.\n\n"
	      
	  ])
	  ~html:None	
      end 
    in
    if success then return $ Task.Finished args else return Task.Failed
  end in 
  MModel.Task.call task
    
let _ = 
  let i18n = MModel.I18n.load (Id.of_string "i18n-common-fr") `Fr in
  let! id, data = Sig.listen MRunOrg.Order.Signals.update in
  if
    data.MRunOrg.Order.Data.status = `Preparing || 
    data.MRunOrg.Order.Data.status = `Correct 
  then 

    let! client = ohm_req_or (return ()) $ 
      MRunOrg.Client.Backdoor.get data.MRunOrg.Order.Data.client
    in

    let! instance = ohm_req_or (return ()) $
      MInstance.get client.MRunOrg.Client.Data.instance 
    in

    let! aid     = req_or (return ()) $ data.MRunOrg.Order.Data.user in
    let! details = ohm $ MAvatar.details aid in 
    
    let! uid     = req_or (return ()) $ details # who in 
    let  uid     = IUser.Assert.can_view uid (* I am an admin, let me look *) in 
    let! user    = ohm_req_or (return ()) $ MUser.get uid in 

    let main, disk = 
      let main, disk = match data.MRunOrg.Order.Data.kind with 
	| `Renew   r -> r # seat # offer, BatOption.map (#offer) (r # memory)
	| `Upgrade u -> u # seat # offer, BatOption.map (#offer) (u # memory)
      in
      let main = match MRunOrg.Offer.check MRunOrg.Offer.main main with 
	| None          -> "-"
	| Some (_,info) -> I18n.translate i18n info # label 
      in
      let disk = match MRunOrg.Offer.check_opt MRunOrg.Offer.memory disk with 
	| None 
	| Some  None           -> "-"
	| Some (Some (_,info)) -> I18n.translate i18n info # label 
      in
      main, disk
    in

    let! _ = ohm begin MAdmin.map 
      begin fun admin ->	
	send_order_mail (object
	  method who    = 
	    (BatOption.default "" user # firstname) ^ " " ^ 
	      (BatOption.default "" user # lastname)
	  method email  = user # email 
	  method main   = main
	  method disk   = disk
	  method paid   = data.MRunOrg.Order.Data.status = `Correct
	  method refer  = Util.base62_to_base34 $ IRunOrg.Order.to_string id
	  method key    = instance # key 
	  method total  = data.MRunOrg.Order.Data.total 
	  method admin  = IUser.decay $ IUser.Deduce.is_self admin 
	end) 
      end
      |> Run.list_map identity
    end in

    return ()
  else
    return ()
