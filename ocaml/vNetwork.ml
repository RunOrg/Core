(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "network" end)

module ItemWithUrl = Loader.Html(struct
  type t = string * I18n.text
  let source  _ = "index/following/with-url"
  let mapping _ = [
    "url",  Mk.str  (fst |- VText.secure_link);
    "name", Mk.trad snd ;
  ]
end)

module ItemNoUrl = Loader.Html(struct
  type t = I18n.text
  let source  _ = "index/following/no-url"
  let mapping _ = [ "name", Mk.trad identity ]
end)

module ItemEdit = Loader.Html(struct
  type t = string
  let source  _ = "index/following/edit"
  let mapping _ = [ "url", Mk.esc identity ]
end)

module FollowingItem = Loader.Html(struct
  type t = <
    edit    : string option ;
    url     : string option ;
    name    : I18n.text ;
    picture : string ;
    access  : VAccessFlag.access option ;
  > ;; 
  let source  _ = "index/following"
  let mapping l = [

    "with-url", Mk.sub_or (fun x -> match x # url with 
      | None -> None
      | Some url -> Some (url, x # name)) (ItemWithUrl.template l) Mk.empty ;

    "no-url", Mk.sub_or (fun x -> if x # url = None then Some (x # name) else None)
      (ItemNoUrl.template l) Mk.empty ;

    "edit", Mk.sub_or (#edit) (ItemEdit.template l) Mk.empty ;
    
    "picture",  Mk.esc   (#picture) ;
    "access",   Mk.ihtml (#access |- VAccessFlag.render_right) ;
  ]
end)

module FollowerItem = Loader.Html(struct
  type t = <
    url     : string ;
    name    : string ;
    picture : string ;
  > ;; 
  let source  _ = "index/followers"
  let mapping l = [
    "name",     Mk.esc  (#name);
    "url",      Mk.esc  (#url) ;
    "picture",  Mk.esc  (#picture) ;
  ]
end)

type index = <
  followers : FollowerItem.t list ;
  followers_count : int ;
  following : FollowingItem.t list ;
  following_count : int ;
  access : VAccessFlag.access option ;
  add : I18n.html ;
  search : I18n.html ;
  name : string 
> ;;

module Index = Loader.Html(struct  
  type t = index
  let source  _ = "index" 
  let mapping l = [
    "following", Mk.list_or (#following) (FollowingItem.template l) Mk.empty ;
    "followers", Mk.list_or (#followers) (FollowerItem.template l) Mk.empty ;
    "access",    Mk.ihtml   (#access |- VAccessFlag.render) ;
    "add-button",       Mk.ihtml (#add) ;
    "search-button",    Mk.ihtml (#search) ;
    "count-followers",  Mk.int   (#followers_count) ;
    "count-following",  Mk.int   (#following_count) ;
    "instance",  Mk.esc     (#name) ;
  ]
end)

module NewRequest = Loader.Text(struct
  type t = string
  let source    = function `Fr -> "new-request-fr"
  let mapping _ = [
    "asso", Mk.str identity ;
  ]
end)

module NewHelp = Loader.Html(struct
  type t = unit
  let source    = function `Fr -> "new-help-fr"
  let mapping _ = []
end)

module New = Loader.Html(struct
  type t = <
    back : string ;
  > ;;
  let source  _ = "new"
  let mapping l = [
    "back", Mk.esc (#back) ;
    "help", Mk.sub (fun _ -> ()) (NewHelp.template l)
  ]
end)

module Edit = Loader.Html(struct
  type t = <
    back : string ;
  > ;;
  let source  _ = "edit"
  let mapping l = [
    "back", Mk.esc (#back) ;
  ]
end)

module ProfileStats = Loader.JsHtml(struct
  type t = <
    url : string ;
    follow : bool ;
    followers : int ;
    broadcasts : int
  > ;;
  let source  _ = "profile-stats"
  let mapping _ = [
    "color", Mk.str (fun x -> if x # follow then " green-button" else "") ;
    "label", Mk.trad (fun x -> if x # follow then `label "digest.follow.yes" else `label "digest.follow.no") ;
    "followers", Mk.int (#followers) ;
    "broadcasts", Mk.int (#broadcasts) 
  ]
  let script  _ = Json_type.Build.([
    "url", (#url |- string) 
  ])
end)

module PublicProfileStats = Loader.Html(struct
  type t = <
    followers : int ;
    broadcasts : int
  > ;;
  let source  _ = "public-profile-stats"
  let mapping _ = [
    "followers",  Mk.int (#followers) ;
    "broadcasts", Mk.int (#broadcasts) 
  ]
end)

module Public = struct

  module SearchTag = Loader.Html(struct
    type t = <
      url   : string ;
      tag   : string ;
      count : int ;
    > ;;
    let source  _ = "public-search/tags"
    let mapping _ = [
      "url",   Mk.esc (#url) ;
      "tag",   Mk.esc (#tag) ;
      "count", Mk.int (#count) 
    ] 
  end)

  module SearchItemTag = Loader.Html(struct
    type t = <
      url : string ;
      tag : string
    > 
    let source  _ = "public-search/list/tags"
    let mapping _ = [
      "tag", Mk.esc (#tag) ;
      "url", Mk.esc (#url) 
    ]
  end)

  module SearchItem = Loader.Html(struct
    type t = <
      picture : string ;
      url     : string ;
      name    : string ;
      desc    : string ;
      tags    : SearchItemTag.t list
    > ;;
    let source  _ = "public-search/list"
    let mapping l = [
      "pic",  Mk.esc  (#picture) ;
      "url",  Mk.esc  (#url) ;
      "name", Mk.esc  (#name) ;
      "desc", Mk.esc  (#desc) ;
      "tags", Mk.list (#tags) (SearchItemTag.template l) 
    ]
  end)

  module Search = Loader.Html(struct
    type t = <
      home : string ;
      list : SearchItem.t list ;
      tags : SearchTag.t list ;
    > ;;
    let source  _ = "public-search"
    let mapping l = [
      "home", Mk.esc  (#home) ;
      "list", Mk.list (#list) (SearchItem.template l) ;
      "tags", Mk.list (#tags) (SearchTag.template l) ;
    ]
  end)

end
