(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module ResendArgs = Fmt.Make(struct
  type json t = <
    nid : INotif.t ;
    uid : IUser.t ;
    act : INotif.Action.t option ;
  >
end)

let task = O.async # define "resend-notif" ResendArgs.fmt 
  begin fun arg -> 

    let token = MNotif.get_token (arg # nid) in 
    MMail.send (arg # uid) begin fun self user send -> 
	
      let url = Action.url UrlMe.Notify.link (user # white) (arg # nid,token,arg # act) in

      let body   = [
	[ `Notif_Resend_Hello (user # fullname) ] ;
	[ `Notif_Resend_Body ]
      ] in

      let button = object
	method color = `Green
	method url   = url 
	method label = `Notif_Resend_Button
      end in 

      let footer = CMail.Footer.core self (user # white) in

      let! m = ohm (VMailBrick.render `Notif_Resend_Title `None body button footer) in

      send ~owid:(user # white) ~from:None ~subject:(m # title) ~text:(m # text) ~html:(m # html) 
	
    end 

  end

let schedule ~nid ~uid ~act =
  O.decay (task (object
    method nid = nid
    method uid = uid
    method act = act
  end))
