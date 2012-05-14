(* © 2012 RunOrg *)

open Ohm
open O

let string = Box.Seg.make None
  (function "" | "-" -> None | s -> Some s) 
  (function Some s -> s | None -> "-")

let order_id = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IRunOrg.Order.of_string s))
  (function Some id -> IRunOrg.Order.to_string id | None -> "-")

let raw_id = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (Id.of_string s))
  (function Some id -> Id.str id | None -> "-")

let avatar_id = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IAvatar.of_string s))
  (function Some id -> IAvatar.to_string id | None -> "-")

let group_id  = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IGroup.of_string s)) 
  (function Some id -> IGroup.to_string id | None -> "-")

let item_id   = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IItem.of_string s))
  (function Some id -> IItem.to_string id | None -> "-")

let entity_id = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IEntity.of_string s))
  (function Some id -> IEntity.to_string id | None -> "-")

let message_id = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IMessage.of_string s))
  (function Some id -> IMessage.to_string id | None -> "-")

let vertical_id = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IVertical.of_string s))
  (function Some id -> IVertical.to_string id | None -> "-")  

let chat_id = Box.Seg.make None
  (function "" | "now" -> None | s -> Some (IChat.Room.of_string s))
  (function Some id -> IChat.Room.to_string id | None -> "now")  

let related_instance_id = Box.Seg.make None 
  (function "" | "-" -> None | s -> Some (IRelatedInstance.of_string s))
  (function Some id -> IRelatedInstance.to_string id | None -> "-")

let instance_id = Box.Seg.make None
  (function "" | "-" -> None | s -> Some (IInstance.of_string s))
  (function Some id -> IInstance.to_string id | None -> "-")

let view_add_order = Box.Seg.make `View
  (function "add" -> `Add | "order" -> `Order | _ -> `View) 
  (function `View -> "view" | `Add -> "add" | `Order -> "order") 

let view_edit = Box.Seg.make `View
  (function "edit" -> `Edit | _ -> `View) 
  (function `View -> "view" | `Edit -> "edit")

let item_or_list = Box.Seg.make `List 
  (function "" | "list" -> `List | s -> `Item (IItem.of_string s))
  (function `List -> "list" | `Item i -> IItem.to_string i)

let entity_options dflt = Box.Seg.make dflt
  (function "fields" -> `Fields | "cols" -> `Cols | "link" -> `Link | "access" -> `Access | _ -> dflt)
  (function `Fields -> "fields" | `Cols -> "cols" | `Link -> "link" | `Access -> "access")

let stats_tabs dflt = Box.Seg.make dflt
  (function 
    | "status" -> `Status
    | other    -> `Field other)
  (function 
    | `Status      -> "status"
    | `Field other -> other)

type add_tabs = 
  [ `Import
  | `Search
  | `FromEntity
  ]

let add_tabs default = Box.Seg.make default
  (function 
    | "import" -> `Import
    | "search" -> `Search
    | "from"   -> `FromEntity
    | _        -> default)
  (function 
    | `Import     -> "import"
    | `Search     -> "search"
    | `FromEntity -> "from")

type entity_tabs = 
  [ `People
  | `Admin_Stats
  | `Wall
  | `Chat
  | `Votes
  | `Admin_Rights
  | `Admin_Columns
  | `Admin_Fields
  | `Admin_Propagate
  | `Info
  | `Admin_Edit
  | `Album
  | `Admin_Payment
  | `Folder
  | `Admin_People 
  ]

let entity_tabs = Box.Seg.make `Info
  (function 
    | "rights" -> `Admin_Rights
    | "edit"   -> `Admin_Edit
    | "cols"   -> `Admin_Columns
    | "fields" -> `Admin_Fields
    | "auto"   -> `Admin_Propagate
    | "p"      -> `Admin_People
    | "pay"    -> `Admin_Payment
    | "people" -> `People
    | "stats"  -> `Admin_Stats
    | "wall"   -> `Wall
    | "chat"   -> `Chat
    | "files"  -> `Folder
    | "album"  -> `Album
    | "info"   -> `Info
    | "votes"  -> `Votes 
    | _        -> `Info)
  (function 
    | `Admin_Rights    -> "rights"
    | `Admin_Edit      -> "edit"
    | `Admin_Columns   -> "cols"
    | `Admin_Fields    -> "fields"
    | `Admin_Propagate -> "auto"
    | `Admin_People    -> "p"
    | `Admin_Payment   -> "pay"
    | `People          -> "people"
    | `Admin_Stats     -> "stats"
    | `Chat            -> "chat"
    | `Wall            -> "wall"
    | `Folder          -> "files"
    | `Album           -> "album"
    | `Votes           -> "votes"
    | `Info            -> "info")

let me_account_tabs dflt = Box.Seg.make dflt
  (function 
    | "edit"  -> `Edit 
    | "share" -> `Share 
    | "pass"  -> `Password 
    | "view"  -> `View
    | "mail"  -> `Receive 
    | _       -> dflt)
  (function 
    | `Edit     -> "edit" 
    | `Share    -> "share" 
    | `Password -> "pass" 
    | `View     -> "view"
    | `Receive  -> "mail")

let me_news_tabs dflt = Box.Seg.make dflt
  (function 
    | "notifications" -> `Notifications 
    | "digest"        -> `Digest
    | _               -> dflt)
  (function 
    | `Notifications  -> "notifications"
    | `Digest         -> "digest")

let me_network_tabs dflt = Box.Seg.make dflt 
  (function 
    | "admin"    -> `Admin
    | "member"   -> `Member
    | "contact"  -> `Contact
    | "requests" -> `Requests
    | "search"   -> `Search
    | "profile"  -> `Profile
    | "follow"   -> `Follow
    | _          -> dflt)
  (function 
    | `Admin    -> "admin"
    | `Member   -> "member"
    | `Contact  -> "contact"
    | `Search   -> "search"
    | `Profile  -> "profile"
    | `Requests -> "requests"
    | `Follow   -> "follow") 

let me_pages = Box.Seg.make `Account
  (function 
    | "network"  -> `Network
    | "news"     -> `News
    | "messages" -> `Messages
    | _          -> `Account)
  (function 
    | `Network  -> "network" 
    | `News     -> "news"
    | `Messages -> "messages"
    | `Account  -> "account")

let broadcast_or_list = Box.Seg.make `List
  (function 
    | "list" -> `List
    | ""     -> `List
    | string -> `Broadcast (IBroadcast.of_string string))
  (function 
    | `List          -> "list"
    | `Broadcast bid -> IBroadcast.to_string bid) 

let myOptions_tabs dflt = Box.Seg.make dflt
  (function "share" -> `Share | "info" -> `Info | _ -> dflt)
  (function `Share -> "share" | `Info -> "info") 

let asso_tabs dflt = Box.Seg.make dflt
  (function 
    | "asso"   -> `Asso
    | "rights" -> `Rights
    | _        -> dflt)
  (function 
    | `Asso   -> "asso"
    | `Rights -> "rights")

let network_tabs = Box.Seg.make `List
  (function 
    | "new"  -> `New
    | "list" -> `List
    | ""     -> `List
    | str    -> `Item (IRelatedInstance.of_string str))
  (function 
    | `New    -> "new"
    | `List   -> "list"
    | `Item i -> IRelatedInstance.to_string i)

let client_tabs dflt = Box.Seg.make dflt
  (function 
    | "client" -> `Client
    | "buy"    -> `Buy
    | "order"  -> `Order
    | _        -> dflt)
  (function 
    | `Client -> "client"
    | `Buy    -> "buy"
    | `Order  -> "order")

type accounting_page = 
  [ `Summary 
  | `NewIn
  | `NewOut
  | `View of IAccountLine.t
  ]

let accounting_pages = Box.Seg.make `Summary
  (function 
    | "summary" -> `Summary
    | ""        -> `Summary
    | "new-in"  -> `NewIn
    | "new-out" -> `NewOut
    | other     -> `View (IAccountLine.of_string other))
  (function 
    | `Summary  -> "summary"
    | `NewIn    -> "new-in"
    | `NewOut   -> "new-out"
    | `View id  -> IAccountLine.to_string id)

type home_pages = 
  [ `Groups         
  | `Subscriptions  
  | `Events         
  | `Forums         
  | `Polls
  | `Contacts          
  | `Options        
  | `Courses        
  | `Calendar
  | `Directory      
  | `Wall           
  | `Asso           
  | `Network
  | `Albums         
  | `Start          
  | `DashMembers    
  | `DashActivities
  | `Accounting     
  | `Feed           
  | `Join
  | `Client
  | `Grants
  | `Profile
  | `Admins
  | `Chat
  ]

let home_pages_pick default = Box.Seg.make default
  (function 
    | "groups"        -> `Groups 
    | "subscriptions" -> `Subscriptions
    | "events"        -> `Events 
    | "forums"        -> `Forums
    | "polls"         -> `Polls
    | "options"       -> `Options 
    | "courses"       -> `Courses
    | "asso"          -> `Asso
    | "network"       -> `Network
    | "directory"     -> `Directory 
    | "wall"          -> `Wall
    | "start"         -> `Start
    | "albums"        -> `Albums
    | "accounting"    -> `Accounting
    | "feed"          -> `Feed
    | "contacts"      -> `Contacts
    | "calendar"      -> `Calendar
    | "members"       -> `DashMembers
    | "activities"    -> `DashActivities
    | "join"          -> `Join
    | "grants"        -> `Grants
    | "client"        -> `Client
    | "profile"       -> `Profile
    | "admins"        -> `Admins
    | "chat"          -> `Chat
    | _               -> default)
  (function
    | `Groups         -> "groups"
    | `Subscriptions  -> "subscriptions"
    | `Events         -> "events"
    | `Forums         -> "forums"
    | `Polls          -> "polls"
    | `Options        -> "options"
    | `Courses        -> "courses"
    | `Directory      -> "directory" 
    | `Wall           -> "wall"
    | `Asso           -> "asso"
    | `Network        -> "network"
    | `Albums         -> "albums"
    | `Start          -> "start"
    | `DashMembers    -> "members"
    | `DashActivities -> "activities"
    | `Contacts       -> "contacts"
    | `Calendar       -> "calendar"
    | `Accounting     -> "accounting"
    | `Feed           -> "feed"
    | `Join           -> "join"
    | `Client         -> "client"
    | `Profile        -> "profile"
    | `Admins         -> "admins"
    | `Grants         -> "grants"
    | `Chat           -> "chat")

let home_pages = home_pages_pick `Wall

type root_pages =
  [ `Profile
  | `Entity
  | `Messages
  | `Message
  | `Home 
  | `AddMembers
  ]

let root_pages = Box.Seg.make `Home
  (function
    | "p"        -> `Profile
    | "e"        -> `Entity
    | "messages" -> `Messages
    | "m"        -> `Message
    | "a"        -> `AddMembers
    | _          -> `Home)
  (function 
    | `Profile    -> "p"
    | `Entity     -> "e"
    | `Messages   -> "messages"
    | `Message    -> "m"
    | `AddMembers -> "a"
    | `Home       -> "home")

type entity = ((unit * root_pages) * IEntity.t option) * entity_tabs
