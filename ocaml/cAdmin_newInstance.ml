(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = Fmt.Make(struct
  type json t = <
    key      : string ;
    name     : string ;      
    vertical : IVertical.t ;
    admin    : IUser.t 
  > 
end)
  
let send_confirm_mail =
  let task = Task.register "adminNotify.new-instance" Data.fmt begin fun args _ ->
    MMail.send_to_self (args # admin)
      begin fun _ _ send ->
	send
	  ~subject:(View.str ("[ADMIN] Création : " ^ args # name))
	  ~text:(fun ctx -> ctx
	    |> View.str "Bonjour, Maître\n\n"
	    |> View.str "Apprenez par la présente qu'un nouvel espace privé (ou profil d'association) a été crée sur RunOrg :\n\n    "
	    |> View.str (args # name)
	    |> View.str " ("
	    |> View.str (args # key)
	    |> View.str ".runorg.com)\n\nIl utilise le vertical :\n\n    "
	    |> View.str (IVertical.to_string (args # vertical)))
	  ~html:None
      end 
    |> Run.map (fun success -> if success then Task.Finished args else Task.Failed)
  end in 
  MModel.Task.call task
    
let _ = 
  let! iid = Sig.listen MInstance.Signals.on_create in
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in 
  MAdmin.map begin fun admin ->	
    send_confirm_mail (object
      method key      = instance # key 
      method name     = instance # name
      method admin    = IUser.Deduce.is_self admin |> IUser.decay
      method vertical = instance # ver
    end) 
  end
  |> Run.list_map identity 
  |> Run.map ignore
