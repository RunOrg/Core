(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Blocks = VSplashBlocks

let _i18n = MModel.I18n.load (Id.of_string "i18n-common-fr") `Fr
  
module PostContactArgs = Fmt.Make(struct
  type json t = <
    phone : string ;
    name  : string ;
    org   : string ;
    message : string
  > 
end)

let post_contact = 
  CCore.profileSessionRegister UrlSplash.post_contact begin fun test req res -> 
    
    Run.eval (new CouchDB.init_ctx) begin
      let  fail = return res in 
      let! args = req_or fail $ PostContactArgs.of_json_safe (req # json) in
      
      let! _ = ohm $ Run.list_map identity (MAdmin.map begin fun admin ->	
	let admin = IUser.Deduce.is_self admin |> IUser.decay in
	MMail.send_to_self admin
	  begin fun _ _ send ->
	    send
	      ~subject:(View.str ("[ADMIN] Demande de contact : " ^ args # name))
	      ~text:(fun ctx -> ctx
		|> View.str "Bonjour, Général !\n\n"
		|> View.str "Nous avons intercepté une communication d'un contact :\n\n    "
		|> View.str (args # name)
		|> View.str " - "
		|> View.str (args # phone)
		|> View.str " - "
		|> View.str (args # org)
		|> View.str "\n\nSon message est :\n\n    "
		|> View.str (args # message))
	      ~html:None	    
	  end 
      end) in
      
      return res
    end
      
  end
