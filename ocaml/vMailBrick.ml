(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

let hr = String.make 70 '-'

type social = <
  pic     : string option ;
  name    : string ; 
  context : string ;
  body    : MRich.OrText.t 
>

module Social = struct

  let render social = 
    let  text = 
      social # name 
      ^ "\n(" ^ social # context ^ ")\n\n" 
      ^ MRich.OrText.to_text (social # body) 
      ^ hr 
    in
    let! html = ohm (Asset_MailBrick_Social.render social) in
    return (object method text = text method html = html end) 

end

type action = <
  pic     : string option ;
  name    : string ; 
  action  : O.i18n ; 
  block   : Ohm.Html.writer ;
>

module Action = struct
  let render action = 
    let text = "" in
    let html = Html.str "" in
    return (object method text = text method html = html end)
end

type payload = 
  [ `None
  | `Social of social 
  | `Action of action ]

module Payload = struct
    
  let render = function 
    | `None     -> return (object method text = "" method html = ignore end)
    | `Social s -> Social.render s 
    | `Action a -> Action.render a 

end

type footer = <
  white : IWhite.t option ;
  name  : string option ;
  url   : string option ;
  unsub : string ;
>

module Footer = struct

  let render footer = 

    let purl = match footer # white with 
      | None -> "http://runorg.com"
      | Some wid -> "http://" ^ ConfigWhite.domain wid 
    in

    let pname = ConfigWhite.name footer # white in
 
    let! no_more = ohm (AdLib.get `MailBrick_Footer_NoMore) in

    let! text, html = ohm begin match footer # name, footer # url with 
      | Some name, Some url -> 
	let! sent_by = ohm (AdLib.get `MailBrick_Footer_SentBy) in
	let! using   = ohm (AdLib.get `MailBrick_Footer_Using) in
	let  text = 
	  sent_by ^ " " ^ name ^ " - " ^ url ^ "\n" ^ using ^ " " ^ pname ^ " - " ^ purl ^ "\n\n"
	  ^ no_more ^ " ~> " ^ (footer # unsub) 
	in
	let  html = Html.(concat [
	  esc sent_by ; 
	  str " <a style=\"color:#89D;text-decoration:none\" href=\"" ;
	  esc url ;
	  str "\">" ;
	  esc name ;
	  str "</a> ";
	  esc using ;
	  str " <a style=\"color:#89D;text-decoration:none\" href=\"" ;
	  esc purl ;
	  str "\">" ;
	  esc pname ;
	  str "</a> · <a style=\"color:#AAA;text-decoration:none\" href=\"" ;
	  esc (footer # unsub) ;
	  str "\">" ;
	  esc no_more ;
	  str "</a>"
	]) in
	return (text, html) 
      | _, _ -> 
	let! sent_by = ohm (AdLib.get `MailBrick_Footer_SentBy) in
	let  text = 
	  sent_by ^ " " ^ pname ^ " - " ^ purl ^ "\n\n"
	  ^ no_more ^ " ~> " ^ (footer # unsub) 
	in
	let  html = Html.(concat [
	  esc sent_by ; 
	  str " <a style=\"color:#89D;text-decoration:none\" href=\"" ;
	  esc purl ;
	  str "\">" ;
	  esc pname ;
	  str "</a> · <a style=\"color:#AAA;text-decoration:none\" href=\"" ;
	  esc (footer # unsub) ;
	  str "\">" ;
	  esc no_more ;
	  str "</a>"
	]) in
	return (text, html) 
    end in 
    
    let! html = ohm (Asset_MailBrick_Footer.render html) in
    
    return (object method text = text method html = html end)

end

type body = O.i18n list list

type button = <
  color : [ `Green | `Grey ] ;
  url   : string ;
  label : O.i18n
>

type result = <
  title : string ; 
  html  : Ohm.Html.writer ;
  text  : string
>

module Body = struct
  
  let render body button =

    let! label = ohm (AdLib.get button # label) in

    let button = object
      method green = button # color = `Green
      method url = button # url 
      method label = label  
    end in

    let! sentences = ohm (Run.list_map (Run.list_map AdLib.get) body) in

    let  text = String.concat "\n\n" (List.map (String.concat " ") sentences) in
    let! html = ohm (Asset_MailBrick_Body.render (object
      method body = sentences
      method button = button 
    end)) in
		    
    let text = text ^ "\n\n  " ^ label ^ " ~> " ^ button # url ^ "\n\n" ^ hr in

    return (object method text = text method html = html end)
    
end

let render (title:O.i18n) (payload:payload) (body:body) (button:button) (footer:footer) = 
  let! payload = ohm (Payload.render payload) in
  let! body = ohm (Body.render body button) in
  let! footer = ohm (Footer.render footer) in
  let  text = payload # text ^ body # text ^ footer # text in
  let! title = ohm (AdLib.get title) in
  let! html = ohm (Asset_MailBrick_Full.render (object
    method title = title 
    method payload = payload # html
    method body = body # html
    method footer = footer # html
  end)) in
  return (object method title = title method text = text method html = html end)
