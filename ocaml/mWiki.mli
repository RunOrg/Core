(* © 2012 RunOrg *)

(* Wiki management ---------------------------------------------------------------------- *)

type 'relation t 
type 'relation wiki = 'relation t 

val naked_get : 'relation IWiki.id -> 'relation t option O.run
val try_get   : 'any # MAccess.context -> IWiki.t -> [`Unknown] t option O.run

val by_key    : IInstance.t -> string -> IWiki.t option O.run

module All : sig

  val get : 'any # MAccess.context -> [`Read] t list O.run

end

module Access : sig

  val can_read  : 'any t -> [`Read]  t option O.run
  val can_write : 'any t -> [`Write] t option O.run
  val can_admin : 'any t -> [`Admin] t option O.run
    
  val get : [`Admin] t -> <
    read  : MAccess.t list ;
    write : MAccess.t list ;
    admin : MAccess.t list
  >

  val get_underlying : [`Admin] t -> <
    read  : MAccess.t ;
    write : MAccess.t ;
    admin : MAccess.t
  >

  val set_underlying : 
       MUpdateInfo.t
    -> [`Admin] IWiki.id
    -> read:  MAccess.t 
    -> write: MAccess.t 
    -> admin: MAccess.t
    -> unit O.run

end

module Get : sig
  val title : [<`Admin|`Write|`Read] t -> I18n.text 
end

val create : 
     MUpdateInfo.t
  -> [`IsAdmin] IInstance.id
  -> title: I18n.text 
  -> read:  MAccess.t 
  -> write: MAccess.t 
  -> admin: MAccess.t
  -> IWiki.t O.run

val update : MUpdateInfo.t -> [<`Admin] IWiki.id -> title:I18n.text -> unit O.run

(* Article management ---------------------------------------------------------------------- *)

module Article : sig

  type revision = {
    title : string ;
    body  : string ;
  }

  type revision_info = {
    data     : revision ;
    date     : float ;
    author   : IAvatar.t ;
    revision : int  ;
    reverted : int option 
  }

  type article = {
    last_title    : string ;
    last_author   : IAvatar.t ;
    last_update   : float ;
    last_revision : int ; 
    instance    : IInstance.t ;
  }

  module Signals : sig
    val on_update : ([`Read] IWiki.Article.id * revision_info) Ohm.Sig.channel
  end 

  val get          : [`Read] IWiki.Article.id -> article option O.run

  val get_latest   : [`Read] IWiki.Article.id -> revision_info option O.run
  val get_revision : [`Read] IWiki.Article.id -> int -> revision_info option O.run
 
  val create : 
       'any # MAccess.context
    -> revision
    -> IWiki.Article.t O.run

  val edit : 
       'any # MAccess.context
    -> [`Write] IWiki.Article.id
    -> revision
    -> unit O.run

  val revert : 
       'any # MAccess.context
    -> [`Write] IWiki.Article.id
    -> int
    -> unit O.run


end
