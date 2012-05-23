(* © 2012 RunOrg *)

module Template : sig

  module Edit : Ohm.Fmt.FMT with type t = 
    <
      kind : MEntityKind.t ;
      name : string ;
      desc : string
    > ;;

  type t = <
    kind    : MEntityKind.t ;
    name    : string ;
    desc    : string ;
    diffs   : (string * MPreConfig.TemplateDiff.t list) list
  > ;;

  val get : 'any ITemplate.id -> t option 

  val admin_all : [`Admin] ICurrentUser.id -> (ITemplate.t * [`label of string | `text of string] * MEntityKind.t) list O.run

  val admin_get : [`Admin] ICurrentUser.id -> ITemplate.t -> Edit.t option O.run

  val admin_set : [`Admin] ICurrentUser.id -> ITemplate.t -> Edit.t -> unit O.run

end

module Step : Ohm.Fmt.FMT with type t = 
  [ `InviteMembers 
  | `AGInvite
  | `WritePost
  | `AddPicture
  | `CreateEvent
  | `CreateAG
  | `AnotherEvent
  | `InviteNetwork
  | `Broadcast ]

type t = <
  t : MType.t ;
  name : string ;
  desc : string ;
  order : string ;
  pricing : string option ;
  catalog : < name : string ; order : string ; box : string > list ;
  summary : string ;
  features : string ;
  parent : IVertical.t option ;
  archive : bool ;
  message : string ;  
  admin : ITemplate.t ;
  group : ITemplate.t list ;
  event : ITemplate.t list ;
  forum : ITemplate.t list ;
  album : ITemplate.t list ;
  poll  : ITemplate.t list ;
  subscription : ITemplate.t list ;
  course : ITemplate.t list ;
  images : string list ;
  subtitle : string option ;
  youcan : string option ;
  thumbs : < image : string ; text : string > list ;
  url : string option ;
  wording : string option ;
  steps : Step.t list ;
> ;;

val reword : t -> [`label of string | `text of string] -> [`label of string | `text of string]

module Edit : Ohm.Fmt.FMT with type t = 
  <
    name : string ;
    desc : string ;
    order : string ;
    pricing : string option ;
    catalog : < name : string ; order : string ; box : string > list ;
    summary : string ;
    archive : bool ;
    message : string ;
    templates : ITemplate.t list ;
    admin : ITemplate.t ;
    features : string ;
    parent : IVertical.t option ;
    images : string list ;
    thumbs : < image : string ; text : string > list ;
    subtitle : string option ;
    youcan : string option ;
    url : string option ;
    wording : string option ;
    steps : Step.t list 
  > ;;

val admin_all : [`Admin] ICurrentUser.id -> (IVertical.t * [`label of string | `text of string] * bool) list O.run

val admin_get : [`Admin] ICurrentUser.id -> IVertical.t -> Edit.t option O.run

val admin_set : [`Admin] ICurrentUser.id -> IVertical.t -> Edit.t -> unit O.run 

val get : IVertical.t -> t option O.run 
val get_cached : IVertical.t -> t O.run 

val default : Edit.t

val by_url : string -> IVertical.t option O.run
val by_parent : IVertical.t -> (IVertical.t * string * [`label of string | `text of string]) list O.run

val get_templates : IVertical.t -> MEntityKind.t -> (ITemplate.t * Template.t) list O.run

val get_event_templates : 
     [`CreateEvent] IInstance.id
  -> IVertical.t
  -> ([`Create] ITemplate.id * Template.t) list O.run

val get_group_templates : 
     [`CreateGroup] IInstance.id
  -> IVertical.t
  -> ([`Create] ITemplate.id * Template.t) list O.run

val get_forum_templates : 
     [`CreateForum] IInstance.id
  -> IVertical.t
  -> ([`Create] ITemplate.id * Template.t) list O.run

val get_album_templates : 
     [`CreateAlbum] IInstance.id
  -> IVertical.t
  -> ([`Create] ITemplate.id * Template.t) list O.run

val get_poll_templates : 
     [`CreatePoll] IInstance.id
  -> IVertical.t
  -> ([`Create] ITemplate.id * Template.t) list O.run

val get_subscription_templates : 
     [`CreateSubscription] IInstance.id 
  -> IVertical.t
  -> ([`Create] ITemplate.id * Template.t) list O.run

val get_course_templates : 
     [`CreateCourse] IInstance.id
  -> IVertical.t
  -> ([`Create] ITemplate.id * Template.t) list O.run

val is_active : IVertical.t -> bool O.run
val get_active : (IVertical.t * t) list O.run
