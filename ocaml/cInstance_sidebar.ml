(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let default_incentives = [
  (object
    method target = "http://runorg.com/help"
    method title  = `label "incentive.help.title"
    method image  = "/public/incentives/help.png"
    method text   = `label "incentive.help.text"
   end) ;
  (object
    method target = "http://runorg.com/start"
    method title  = `label "incentive.start.title"
    method image  = "/public/incentives/start.png"
    method text   = `label "incentive.start.text"
   end)
]

let sections ctx = 
  if ctx # instance # stub then
    [ `Profile  ; `Network ; `Asso ]      
  else if None = IIsIn.Deduce.is_token (ctx # myself) then 
    if CContext.is_ag ctx then 
      [ `Profile ; `Join ; `Groups ; `Events ; `Options ]  
    else
      [ `Profile ; `Network ; `Join ; `DashMembers ; `DashActivities ; `Options ] 
  else
    if CContext.is_ag ctx then
      [ `Profile ; `Groups ; `Events ; `Options ; `Start ] 
    else
      [ `Wall ; `DashMembers ; `DashActivities ; `Options ; `Start ] 

let subsections ctx = function
  | `DashMembers    -> [ `Contacts ; `Grants ; `Directory ; `Groups ; `Subscriptions ]
  | `DashActivities -> [ `Calendar ; `Events ; `Courses ; `Albums ; `Polls ; `Forums ] 
  | `Start          -> [ `Start ; `Asso ; `Admins ; `Client ; `Accounting ] 
  | `Asso           -> [ `Start ; `Asso ; `Admins ]
  | `Wall           -> [ `Profile ; `Network ; `Chat ; `Feed ] 
  | `Profile        -> if CContext.is_ag ctx then [ `Network ] else []
  | `Groups         -> if CContext.is_ag ctx then [ `Directory ] else []
  | _               -> []
  
let find_section ctx key available = 
  let found    = List.assoc key available in 
  let sections = sections ctx in
  let all      = List.concat (sections :: List.map (subsections ctx) sections) in
  if List.mem key all then found else raise Not_found
    
(* Sidebar rendering *)

let render_sidebar ctx input prefix current available = 
  let url seg = UrlR.build (ctx # instance) (input # segments) (prefix,seg) in
  let icon = function 
    | `Profile        -> VIcon.vcard
    | `Feed           -> VIcon.text_dropcaps
    | `Wall           -> VIcon.text_padding_top
    | `Asso           -> VIcon.pencil
    | `Calendar       -> VIcon.calendar
    | `Courses        -> VIcon.of_entity_kind `Course
    | `Groups         -> VIcon.of_entity_kind `Group 
    | `Events         -> VIcon.of_entity_kind `Event
    | `Forums         -> VIcon.of_entity_kind `Forum
    | `Subscriptions  -> VIcon.of_entity_kind `Subscription
    | `Albums         -> VIcon.of_entity_kind `Album
    | `Polls          -> VIcon.of_entity_kind `Poll 
    | `DashMembers    -> VIcon.shading
    | `DashActivities -> VIcon.shading
    | `Join           -> VIcon.shading
    | `Directory      -> VIcon.group
    | `Start          -> VIcon.lightning
    | `Options        -> VIcon.wrench
    | `Accounting     -> VIcon.coins
    | `Contacts       -> VIcon.chart_line
    | `Grants         -> VIcon.key
    | `Client         -> VIcon.application_key
    | `Network        -> VIcon.color_wheel
    | `Admins         -> VIcon.user_gray
    | `Chat           -> VIcon.comments 
  in
  let label ctx = function 
    | `Profile        -> `label "menu.profile" 
    | `Feed           -> `label "menu.feed"
    | `Wall           -> ctx # reword (`label "menu.wall")
    | `Asso           -> `label "menu.asso"
    | `Courses        -> `label "menu.courses"
    | `Groups         -> `label "menu.groups"
    | `Events         -> `label "menu.events" 
    | `Forums         -> `label "menu.forums"
    | `Subscriptions  -> `label "menu.subscriptions" 
    | `Albums         -> `label "menu.albums" 
    | `Polls          -> `label "menu.polls"
    | `Directory      -> `label "menu.directory"
    | `Start          -> `label "menu.start"
    | `Options        -> `label "menu.myself"
    | `Accounting     -> `label "menu.accounting"
    | `Calendar       -> `label "menu.calendar"
    | `DashMembers    -> `label "menu.members"
    | `DashActivities -> `label "menu.activities"
    | `Contacts       -> `label "menu.contacts"
    | `Join           -> `label "menu.join"
    | `Grants         -> `label "menu.grants"
    | `Client         -> `label "menu.client"
    | `Network        -> `label "menu.network"
    | `Admins         -> `label "menu.admins"
    | `Chat           -> `label "menu.chat"
  in

  let is_admin = function
    | `Start 
    | `Asso  -> true
    | _      -> false
  in 

  let subsection ctx key =
    if List.mem_assoc key available then
      Some (object
	method selected = current = key
	method url      = url   key
	method label    = label ctx key
	method icon     = icon  key 
      end) 
    else None
  in

  let section ctx key = 
    let subsections = subsections ctx key in 
    if List.mem_assoc key available
    && ( List.exists (fun sub -> List.mem_assoc sub available) subsections 
	 || subsections = [] )
    then
      let selected = List.mem current (key :: subsections) in
      Some (object
	method selected = selected
	method opened   = selected
	method admin    = is_admin key 
	method url      = url key 
	method label    = if is_admin key then `label "menu.admin" else label ctx key 
	method contents = BatList.filter_map (subsection ctx) subsections
      end)
    else None
  in

  BatList.filter_map (section ctx) (sections ctx)

(* Rendering the actual tabs in the sidebar *)

let tabs ctx forbidden available =

  let default = 
    if CContext.is_ag ctx then `Profile 
    else if None = IIsIn.Deduce.is_token (ctx # myself) then `Profile
    else `Wall 
  in 

  let content = "c" in
  O.Box.node begin fun input (prefix,url) ->
    let sub_boxes = 
      let box = try find_section ctx url available with Not_found -> forbidden in 
      return [ content, box ]      
    and body = 

      let! pic = ohm (CPicture.large (ctx # instance # pic)) in

      let! vertical = ohm $ MVertical.get (ctx # instance # ver) in
      let  message = if ctx # instance # stub then "" else BatOption.default "" $ BatOption.map (#message) vertical in 

      let sidebar = render_sidebar ctx input prefix url available in

      let! follow = ohm begin       
	let  iid = IInstance.decay (IIsIn.instance (ctx # myself)) in
	let cuid = IIsIn.user (ctx # myself) in
	let  uid = IUser.Deduce.unsafe_is_anyone cuid in
	let! is_admin = ohm $ MAvatar.is_admin ~other_than:iid uid in
	let  url = UrlMe.build 
	  O.Box.Seg.(UrlSegs.(
	    root ++ me_pages ++ me_network_tabs `Follow ++ instance_id))
	  ((((),`Network),`Follow),Some iid)
	in
	if is_admin then 
	  return $ VCore.FollowLinkButton.render url
	else
	  return (fun _ -> Ohm.View.str "&nbsp;") 
      end in

      let incentives = if ctx # white = None then default_incentives else [] in

      let data = object
	method follow     = follow
	method box        = (input#name, content)
	method incentives = incentives
	method picture    = pic
	method message    = message
	method name       = ctx # instance # name
	method sidebar    = sidebar
	method home       = UrlR.build (ctx # instance) (input # segments) (prefix,default) 
      end in

      return (VInstance.Sidebar.render data (ctx # i18n)) 
    in

    sub_boxes, body
  end
  |> O.Box.parse (CSegs.home_pages_pick default)
