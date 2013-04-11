(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Mail = MMail.Register(struct
  include (IUser : Ohm.Fmt.FMT with type t = IUser.t) 
  let id = IMail.Plugin.of_string "confirm"
  let iid _ = None
  let uid = identity 
  let from _ = None
  let solve _ = None
  let item _ = false
end)

let () = Mail.define begin fun uid u _ info -> 
  return (Some (object
    method item = None
    method act _ = return (Action.url UrlMe.News.home (u # white) ())
    method mail = let title = `Mail_SignupConfirm_Title in

		  let body  = [
		    [ `Mail_SignupConfirm_Intro (u # fullname) ] ;
		    [ `Mail_SignupConfirm_Explanation (u # email) ] ; 
		  ] in
		  
		  let buttons = [ VMailBrick.green `Mail_PassReset_Button 
				    (CMail.link (info # id) None (u # white)) ] in
		  
		  return (title,`None,body,buttons)
  end))
end 

