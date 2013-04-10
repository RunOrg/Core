(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Footer = CMail_footer

module ResendArgs = Fmt.Make(struct
  type json t = <
    mid : IMail.t ;
    uid : IUser.t ;
    act : IMail.Action.t option ;
  >
end)

let task = O.async # define "resend-mail" ResendArgs.fmt 
  begin fun arg -> 

    let token = MMail.get_token (arg # mid) in 
    MMail.Send.send (arg # uid) begin fun self user send -> 
	
      let url = Action.url UrlMail.link (user # white) (arg # mid,token,arg # act) in

      let body   = [
	[ `Notif_Resend_Hello (user # fullname) ] ;
	[ `Notif_Resend_Body ]
      ] in

      let button = object
	method color = `Green
	method url   = url 
	method label = `Notif_Resend_Button
      end in 

      let footer = Footer.core (arg # mid) self (user # white) in

      let! m = ohm (VMailBrick.render `Notif_Resend_Title `None body button footer) in

      send ~owid:(user # white) ~subject:(m # title) ~text:(m # text) ~html:(m # html) ()
	
    end 

  end

let schedule ~mid ~uid ~act =
  O.decay (task (object
    method mid = mid
    method uid = uid
    method act = act
  end))
