(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = Fmt.Make(struct
  module IUser = IUser
  type json t = <
    user  : IUser.t ;
    email : string ;
    name  : string ;      
    assos : string list ;
    admin : IUser.t 
  > 
end)
  
let send_confirm_mail =
  let task = Task.register "adminNotify.confirm" Data.fmt begin fun args _ ->
    MMail.send_to_self (args # admin)
      begin fun _ _ send ->
	send
	  ~subject:(View.str ("[ADMIN] Inscrit : " ^ args # name))
	  ~text:(fun ctx -> ctx
	    |> View.str "Bonjour, Maître\n\n"
	    |> View.str "Apprenez par la présente qu'un très honorable client a crée et confirmé son compte RunOrg :\n\n    "
	    |> View.str (args # name)
	    |> View.str " - "
	    |> View.str (args # email)
	    |> View.str "\n\nIl est déjà contact des associations suivantes :\n\n    "
	    |> View.str (String.concat ", " (args # assos)))
	  ~html:None
      end 
    |> Run.map (fun success -> if success then Task.Finished args else Task.Failed)
  end in 
  MModel.Task.call task
    
let _ = 
  let! id, user = Sig.listen MUser.Signals.on_confirm in
  let! assos = ohm begin
    let! list  = ohm $ MAvatar.Backdoor.user_instances id in
    Run.list_filter (fun (_, iid) -> 
      MInstance.get iid |> Run.map (BatOption.map (#name))
    ) list 
  end in
  MAdmin.map begin fun admin ->	
    send_confirm_mail (object
      method user  = IUser.decay id
      method email = user # email
      method name  = user # fullname
      method admin = IUser.Deduce.is_self admin |> IUser.decay
      method assos = assos
    end) 
  end
  |> Run.list_map identity 
  |> Run.map ignore
      
