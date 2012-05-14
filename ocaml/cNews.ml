(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal


let tabs ~i18n ~user = 
  let! has_unread_notifications = ohm $ CNotification.has_unread user in
  let  default = if has_unread_notifications then `Notifications else `Digest in
  return $ CTabs.box 
    ~list:[ CTabs.fixed `Notifications (`label "me.news.tab.notifications")
	      (lazy (CNotification.box ~i18n ~user)) ;
	    CTabs.fixed `Digest (`label "me.news.tab.digest")
	      (lazy (CDigest.box ~i18n ~user)) ;
	  ]
    ~url:(UrlMe.build)
    ~default
    ~seg:CSegs.me_news_tabs
    ~i18n
    
let box ~user ~i18n =
  let content = "t" in
  O.Box.node begin fun bctx _ -> 
    ( let! tabs = ohm $ tabs ~i18n ~user in
      return [content, tabs] ),
    return (VMe.News.render (bctx # name, content) i18n) 
  end

