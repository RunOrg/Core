(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

type nospam = <
  link : bool -> string ;
  name : string ; 
  pic  : string option ;
> 

module NoSpam = struct

  let render nospam = 
    Asset_MailBrick_NoSpam.render (object
      method ok   = nospam # link true
      method no   = nospam # link false
      method pic  = nospam # pic
      method name = nospam # name
    end)

end

let hr = String.make 70 '-'

type dual = <
  html : Ohm.Html.writer ;
  text : string
>

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
  detail  : dual ; 
>

module Action = struct

  let render action = 
    let! act = ohm (AdLib.get (action # action)) in
    let  text = 
      action # name 
      ^ " " ^ act ^ "\n\n"
      ^ action # detail # text 
      ^ "\n\n" ^ hr 
    in
    let! html = ohm (Asset_MailBrick_Action.render action) in
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
  track : string ; 
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

    let! track = ohm (Asset_MailBrick_Track.render (footer # track)) in
    let  html = Html.(concat [ html ; track ]) in
    
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
  subject : string ; 
  html    : Ohm.Html.writer ;
  text    : string ;
  from    : string option ; 
>

module Body = struct
  
  let render body buttons =

    let! buttons = ohm $ Run.list_map begin fun button -> 
      let! label = ohm (AdLib.get button # label) in
      return (object
	method green = button # color = `Green
	method url = button # url 
	method label = label  
      end)
    end buttons in

    let! sentences = ohm (Run.list_map (Run.list_map AdLib.get) body) in

    let  text = String.concat "\n\n" (List.map (String.concat " ") sentences) in
    let! html = ohm (Asset_MailBrick_Body.render (object
      method body = sentences
      method buttons = buttons 
    end)) in
		    
    let text = 
      text ^ "\n\n  " 
      ^ String.concat "\n" (List.map (fun b -> b # label ^ " ~> " ^ b # url) buttons) 
      ^ "\n\n" ^ hr 
    in

    return (object method text = text method html = html end)
    
end

let green label url = object
  method color = `Green
  method url = url
  method label = label
end

let grey label url = object
  method color = `Grey
  method url = url
  method label = label
end

let render ?nospam ?from title (payload:payload) (body:body) (buttons:button list) (footer:footer) = 
  let! payload = ohm (Payload.render payload) in
  let! body = ohm (Body.render body buttons) in
  let! footer = ohm (Footer.render footer) in
  let  text = payload # text ^ "\n\n" ^ body # text ^ "\n\n" ^ footer # text in
  let! title = ohm (AdLib.get title) in
  let! nospam = ohm (Run.opt_map NoSpam.render nospam) in
  let! html = ohm (Asset_MailBrick_Full.render (object
    method title = title 
    method nospam = nospam
    method payload = payload # html
    method body = body # html
    method footer = footer # html
  end)) in
  return (object 
    method from = from 
    method subject = title 
    method text = text 
    method html = html 
  end)

let boxProfile ?img ~detail ~name url =
  let  _, summary = MRich.OrText.summary detail in 
  let! html = ohm (Asset_MailBrick_BoxProfile.render (object
    method url = url
    method img = img
    method name = name
    method detail = MRich.OrText.to_html summary 
  end)) in

  let text = 
    name ^ "\n("
    ^ url ^ ")\n\n" 
    ^ MRich.OrText.to_text summary
    ^ "\n\n"
    ^ hr
    ^ "\n"
  in

  return (object
    method text = text
    method html = html 
  end)

let boxTask ~name ?subtitle ~status ~color url = 
  let! html = ohm (Asset_MailBrick_BoxTask.render (object
    method url = url
    method name = name
    method subtitle = subtitle
    method status = status
    method fontcolor = match color with 
    | `Green -> "#060"
    | `Red -> "#600"
    method bordercolor = match color with 
    | `Green -> "#4C4"
    | `Red -> "#C44"
    method backcolor = match color with
    | `Green -> "#8E8"
    | `Red -> "#E88"
  end)) in

  let text = 
    name ^ "\n("
    ^ url ^ ")\n\n"
    ^ (match subtitle with None -> "" | Some subtitle -> subtitle ^ "\n\n")
    ^ hr
    ^ "\n"
  in
  
  return (object
    method text = text
    method html = html
  end)
