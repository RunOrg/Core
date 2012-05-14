(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "notification" name

let _not_found =   
  let _fr = load "not_found-fr" [ 
    "url",       Mk.esc (#url) ;
    "title",     Mk.trad (#title) ;
    "index.url", Mk.esc (#index) 
  ] `Html in
  function `Fr -> _fr

let not_found ~url ~index ~title i18n ctx = 
  let template = _not_found (I18n.language i18n) in
  to_html template (object 
    method url   = url
    method title = title
    method index = index
  end) i18n ctx

module Item = struct
    
  type item_content = <
    instance : string ;
    picture  : string ;
    time     : float ;
    url      : string ;
    icon     : string ;
    message  : I18n.t -> View.Context.box View.t ;
    isnew    : bool 
  > ;;

  let item_content ~instance ~message ~picture ~url ~time ~icon ~isnew = 
    (object
      method instance = instance
      method message  = message 
      method picture  = picture
      method time     = time
      method url      = url
      method icon     = icon
      method isnew    = isnew
     end : item_content)

  let join_pending ~entity ~from = 
    item_content ~icon:VIcon.exclamation
      ~message:(fun i18n -> I18n.get_param i18n "news.join_pending" [View.esc from;I18n.get i18n entity])

  let comment_item ~from ~author = 
    item_content ~icon:VIcon.comments
      ~message:(fun i18n -> I18n.get_param i18n "news.comment_item" [View.esc from;View.esc author]) 
      
  let comment_their_item ~from =
    item_content ~icon:VIcon.comments
      ~message:(fun i18n -> I18n.get_param i18n "news.comment_their_item" [View.esc from])

  let comment_your_item ~from = 
    item_content ~icon:VIcon.comments
      ~message:(fun i18n -> I18n.get_param i18n "news.comment_your_item" [View.esc from])

  let like_item ~from ~author = 
    item_content ~icon:VIcon.star
      ~message:(fun i18n -> I18n.get_param i18n "news.like_item" [View.esc from;View.esc author])
      
  let like_their_item ~from = 
    item_content ~icon:VIcon.star
      ~message:(fun i18n -> I18n.get_param i18n "news.like_their_item" [View.esc from])
      
  let like_your_item ~from = 
    item_content ~icon:VIcon.star
      ~message:(fun i18n -> I18n.get_param i18n "news.like_your_item" [View.esc from])
      
  let publish_item ~from = 
    item_content ~icon:VIcon.comment_add
      ~message:(fun i18n -> I18n.get_param i18n "news.publish_item" [View.esc from])

  let chat_request ~where ~topic ~from = 
    item_content ~icon:VIcon.comments_add
      ~message:(fun i18n -> I18n.get_param i18n "news.chat_request" [
	View.esc from ; I18n.get i18n where ; View.esc topic ])

  let network_invite ~from = 
    item_content ~icon:VIcon.color_wheel
      ~message:(fun i18n -> I18n.get_param i18n "news.network_invite" [View.esc from]) 

  let network_connect ~from ~instance = 
    item_content ~instance ~icon:VIcon.color_wheel
      ~message:(fun i18n -> I18n.get_param i18n "news.network_connect" 
	[View.esc from ; View.esc instance]) 

  let become_member ~from =  
    item_content ~icon:VIcon.user_red
      ~message:(fun i18n -> I18n.get_param i18n "news.become_member" [View.esc from])
            
  let become_admin ~from =   
    item_content ~icon:VIcon.user_gray
      ~message:(fun i18n -> I18n.get_param i18n "news.become_admin" [View.esc from])
      
  let invite_subscription ~from ~instance = 
    item_content ~instance ~icon:(VIcon.of_entity_kind `Subscription)
      ~message:(fun i18n -> I18n.get_param i18n "news.invite_subscription" [View.esc from;View.esc instance])

  let invite_event ~from = 
    item_content ~icon:(VIcon.of_entity_kind `Event)
      ~message:(fun i18n -> I18n.get_param i18n "news.invite_event" [View.esc from])

  let invite_group ~from = 
    item_content ~icon:(VIcon.of_entity_kind `Group)
      ~message:(fun i18n -> I18n.get_param i18n "news.invite_group" [View.esc from])

  let invite_forum ~from = 
    item_content ~icon:(VIcon.of_entity_kind `Forum)
      ~message:(fun i18n -> I18n.get_param i18n "news.invite_forum" [View.esc from])

  let invite_album ~from = 
    item_content ~icon:(VIcon.of_entity_kind `Album)
      ~message:(fun i18n -> I18n.get_param i18n "news.invite_album" [View.esc from])

  let invite_poll ~from = 
    item_content ~icon:(VIcon.of_entity_kind `Poll)
      ~message:(fun i18n -> I18n.get_param i18n "news.invite_poll" [View.esc from])

  let invite_course ~from = 
    item_content ~icon:(VIcon.of_entity_kind `Course)
      ~message:(fun i18n -> I18n.get_param i18n "news.invite_course" [View.esc from])

end

let _item = 
  let _fr = load "item" [
    "instance",   Mk.esc   (#instance) ;
    "picture",    Mk.esc   (#picture) ;
    "time",       Mk.ihtml (#time |- VDate.render) ;
    "url",        Mk.esc   (#url) ;
    "icon",       Mk.esc   (#icon) ;
    "message",    Mk.ihtml (#message) ;
    "isnew",      Mk.str   (fun x -> if x # isnew then " is-new" else "") ;
  ] `Html in
  function `Fr -> _fr
    
let _empty = VCore.empty VIcon.Large.flag_yellow (`label "me.news.empty")
  
let _full = 
  let _fr = load "full" [
    "me.news.content", Mk.list_or (#content) (_item `Fr) (_empty);
  ] `Html in  
  function `Fr -> _fr 
    
let full ~content ~i18n ctx = 
  let template = _full (I18n.language i18n) in 
  to_html template (object 
    method content    = (content : Item.item_content list) 
  end) i18n ctx
