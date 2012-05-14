(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let layout ~js ~title ~body response = 
    Layout.render
      ~js_files:[ "http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js" ;
		  "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/jquery-ui.min.js" ;
		  "/public/js/jquery.json-2.2.min.js" ;
		  "/public/js/jog.js" ;
		  "/public/js/joy-0.8.js" ;
		  "/public/js/admin.js" ;
		  "/public/js/runorg.js" ]
      ~css_files:[ "/public/css/jqueryui-aristo/jquery-ui-1.8.4.custom.css" ;
		   "/public/css/joy.css" ]
      ~title ~body ~js response    

let register url action = 
  CCore.User.register url begin fun i18n user request response ->
    
    let fail = return (Action.redirect (UrlLogin.index # build) response) in
    
    let! user = req_or fail $ MAdmin.user_is_admin user in

    action i18n user request response

  end

  
