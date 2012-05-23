(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Json_type
open BatPervasives
open Ohm.Universal

module MyDB = MModel.TemplateDB

module Template = struct

  module Design = struct
    module Database = MyDB
    let name = "template"
  end   

  module Data = Fmt.Make(struct
    type json t = <
     ?t      : MType.t = `EntityTemplate ;
      kind   : MEntityKind.t ;
      name   : string ;
     ?desc   : string = "" 
    > 
  end)

  type t =  <
    kind    : MEntityKind.t ;
    name    : string ;
    desc    : string ;
    diffs   : (string * MPreConfig.TemplateDiff.t list) list
  > ;;

  module MyTable = CouchDB.Table(MyDB)(ITemplate)(Data)
    
  let all = Hashtbl.create 100

  module AllView = CouchDB.DocView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name = "all"
    let map  = "if (doc.t == 'etmp') emit(null,null);" 
  end)

  let _preload_all_templates = 
    if Util.role <> `Put then begin 

      let preload = 

	let c_string = Compressor.basic () in
		
	let template id doc = 
	  let versions = MPreConfig.applies_to id MPreConfig.template_versions in
	  ( object
	    	    
	    val       name = c_string (doc # name)
	    method    name = name
	      	      
	    val       desc = c_string (doc # desc) 
	    method    desc = desc
	      
	    val       kind = doc # kind
	    method    kind = kind
	            
	    val      diffs = List.map (fun version -> version # version, version # payload) versions
	    method   diffs = diffs
	      
	    end )
	in
      
	let! load = ohm $ AllView.doc_query () in

	let () = 
	  List.iter 
	    begin fun item ->
	      let id = ITemplate.of_id (item # id) in
	      log "Template.preload : loading %s" (Id.str (item # id)) ;
	      Hashtbl.add all id (template id (item # doc))
	    end 
	    load 
	in

	let () = 
	  log "Template.preload : estimated %d bytes of memory used"
	    (String.length (Marshal.to_string all [Marshal.Closures]))
	in
	
	return ()

      in
      
      try Run.eval (new CouchDB.init_ctx)  preload with exn -> 
	log "FAIL : error %s when precaching templates" (Printexc.to_string exn)
      
    end
    
  let get id = 
    try Some (Hashtbl.find all (ITemplate.decay id))
    with Not_found -> None

  module Edit = Fmt.Make(struct

(*
    let edit = JoyA.obj [
      JoyA.field "name" ~label:"Nom" (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) ;
      JoyA.field "desc" ~label:"Description" (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) ;
      JoyA.field "kind" ~label:"Type" (JoyA.variant [
	JoyA.alternative ~label:"Groupe" "Group" ;
	JoyA.alternative ~label:"Evènement" "Event" ;
	JoyA.alternative ~label:"Adhésion" "Subscription" ;
	JoyA.alternative ~label:"Forum" "Forum" ;
	JoyA.alternative ~label:"Sondage" "Poll" ;
	JoyA.alternative ~label:"Album" "Album" ;
	JoyA.alternative ~label:"Cours" "Course"
      ])
    ]
*)

    type json t = <
      name : string ;
      desc : string ;
      kind : MEntityKind.t
    >

  end)

  let admin_all _ = 
    let! all = ohm (AllView.doc_query ()) in
    return (all |> List.map (fun item ->       
      ITemplate.of_id (item # id), `label (item # doc # name), (item # doc # kind)
    ) |> List.sort (fun (a,_,_) (b,_,_) -> compare a b))

  let admin_get _ id = 
    let! template = ohm_req_or (return None) (MyTable.get id) in

    let result = object
      method name  = template # name
      method desc  = template # desc
      method kind  = template # kind
    end in 

    return (Some result)

  let admin_set _ id edit = 
    
    let obj = object
      method name = edit # name
      method desc = edit # desc
      method kind = edit # kind
      method t    = `EntityTemplate
    end in 

    MyTable.transaction id (MyTable.insert obj) |> Run.map ignore   

end

module Design = struct
  module Database = MyDB
  let name = "vertical"
end

let admin_default = ITemplate.of_string "admin" 

module Step = Fmt.Make(struct
  type json t = 
    [ `InviteMembers 
    | `AGInvite
    | `WritePost
    | `AddPicture
    | `CreateEvent
    | `CreateAG
    | `AnotherEvent 
    | `InviteNetwork
    | `Broadcast ]
end)

module StepList = Fmt.Make(struct
  type json t = Step.t list
  let t_of_json = function 
    | Json_type.Array l -> BatList.filter_map Step.of_json_safe l
    | _ -> assert false
end)

let default_steps = 
  [ `InviteMembers 
  ; `WritePost
  ; `AddPicture
  ; `InviteNetwork
  ; `Broadcast
  ; `CreateEvent
  ; `AnotherEvent 
  ]

module Data = Fmt.Make(struct
  type json t = <
   ?t       : MType.t = `Vertical ;
    name    : string ;
   ?order   : string = "" ;
   ?pricing : string option ;
   ?catalog : < name : string ; order : string ; box : string > list = [] ;
   ?summary : string = "" ;
   ?archive : bool = false ;
   ?admin   : ITemplate.t = admin_default ;
   ?group   : ITemplate.t list = [] ;
   ?forum   : ITemplate.t list = [] ;
   ?album   : ITemplate.t list = [] ;
   ?poll    : ITemplate.t list = [] ;
   ?course  : ITemplate.t list = [] ;
    event   : ITemplate.t list ;
   ?subscription : ITemplate.t list = [] ;
   ?message  : string = "" ;
   ?desc     : string = "" ;
   ?features : string = "" ;
   ?parent   : IVertical.t option ;
   ?images   : string list = [] ;
   ?thumbs   : < image : string ; text : string > list = [] ;
   ?youcan   : string option ;
   ?subtitle : string option ;
   ?url      : string option ;
   ?wording  : string option ;
   ?steps    : StepList.t = default_steps 
  > 
end)

module MyTable = CouchDB.Table(MyDB)(IVertical)(Data)

include Data

let get     id = MyTable.get (IVertical.decay id)

let default = object
  method name = ""
  method desc = ""
  method summary = ""
  method order = ""
  method parent = None
  method features = ""
  method archive = false
  method images = []
  method pricing = None
  method catalog = []
  method admin = ITemplate.of_string "admin"
  method templates = []
  method message = ""
  method images = []
  method thumbs = []
  method subtitle = None
  method youcan = None
  method url = None
  method wording = None
  method steps = default_steps
end

let get_cached = memoize (fun id -> (get id |> Run.map (BatOption.default (object
  method t      = `Vertical
  method name    = ""
  method desc    = ""
  method summary = ""
  method order   = ""
  method parent  = None
  method features = ""
  method archive = false
  method images  = []
  method pricing = None
  method catalog = []
  method admin   = ITemplate.of_string "admin"
  method group   = []
  method forum   = []
  method album   = []
  method poll    = []
  method course  = []
  method event   = []
  method subscription = [] 
  method message  = ""
  method images   = []
  method thumbs   = []
  method subtitle = None
  method youcan  = None
  method url     = None
  method wording = None
  method steps   = default_steps
end
))) |> Run.memo)
  
module ByUrlView = CouchDB.DocView(struct
  module Key = Fmt.String
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by_url"
  let map = "if (doc.t == 'vert' && doc.url) emit(doc.url,null);"
end)

let reword vertical = function 
  | `text  t -> `text t
  | `label l -> match vertical # wording with 
      | None   -> `label l 
      | Some w -> `label (l ^ ":" ^ w)  

let by_url url = 
  let! list = ohm (ByUrlView.doc url) in
  match list with
    | []     -> return None
    | h :: _ -> return (Some (IVertical.of_id (h # id)))

module ByParentView = CouchDB.MapView(struct
  module Key = IVertical
  module Value = Fmt.Make(struct
    type json t = string * string
  end)
  module Design = Design
  let name = "by_parent"
  let map = "if (doc.t == 'vert' && !doc.archive && doc.url && doc.parent)
               emit(doc.parent,[doc.url,doc.name]);"
end)

let by_parent id = 
  let! list = ohm (ByParentView.by_key id) in
  return (List.map (fun item ->
    IVertical.of_id (item # id),
    fst (item # value) ,
    `label (snd (item # value))
  ) list)

module InVertical = Fmt.Make(struct
  type json t = IVertical.t * MEntityKind.t
end)

module InVerticalTemplates = Fmt.Make(struct
  type json t = ITemplate.t list
end)

module InVerticalView = CouchDB.MapView(struct
  module Key = InVertical
  module Value = InVerticalTemplates
  module Design = Design
  let name = "in_vertical"
  let map    = "if (doc.t == 'vert') { 
                  function process(k,K) {
                    emit([doc._id,K],doc[k]);
                  }
 
                  process('event','Event');
                  process('group','Group');
                  process('forum','Forum');
                  process('poll','Poll');
                  process('album','Album');
                  process('subscription','Subscription');
                  process('course','Course');
                }" 
end)

let get_templates vertical (kind : MEntityKind.t) =   
  let! list = ohm (InVerticalView.by_key (IVertical.decay vertical, kind)) in
  let list = List.concat (List.map (#value) list) in
    
  return (
    BatList.filter_map begin fun id -> 
      match Template.get id with 
	| None -> None 
	| Some template -> Some (id,template)
    end list
  ) 

let can_create_kind kind vertical = 
  get_templates vertical kind |> Run.map 
      (List.map (fun (i,d) -> ITemplate.Assert.can_create i, d))

let get_event_templates        _ vertical = can_create_kind `Event vertical 
let get_group_templates        _ vertical = can_create_kind `Group vertical
let get_forum_templates        _ vertical = can_create_kind `Forum vertical
let get_album_templates        _ vertical = can_create_kind `Album vertical
let get_poll_templates         _ vertical = can_create_kind `Poll vertical
let get_subscription_templates _ vertical = can_create_kind `Subscription vertical 
let get_course_templates       _ vertical = can_create_kind `Course vertical

module ArchivedView = CouchDB.DocView(struct
  module Key = Fmt.Bool
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "archived"
  let map = "if (doc.t == 'vert') emit(doc.archive || false,null);" 
end)

let get_active = 
  let! active = ohm $ ArchivedView.doc_query
    ~startkey:false ~endkey:false ~endinclusive:true ()
  in
  let list = List.map (fun item -> IVertical.of_id (item # id), item # doc) active in
  let sorted = List.sort (fun (_,a) (_,b) -> compare a # order b # order) list in
  return sorted

let is_active id = 
  MyTable.get (IVertical.decay id) |> Run.map begin function
    | None -> false
    | Some vertical -> not (vertical # archive) 
  end

module Edit = Fmt.Make(struct
    
(*
  let edit = JoyA.obj [
    JoyA.field "name" ~label:"Nom" (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) ;
    JoyA.field "desc" ~label:"Description"  (JoyA.string ~editor:`area ()) ;
    JoyA.field "order" ~label:"Tri" (JoyA.string ()) ;
    JoyA.field "steps" ~label:"Start" (JoyA.array (JoyA.variant [
      JoyA.alternative ~label:"Inviter des membres" "InviteMembers" ;
      JoyA.alternative ~label:"Inviter des membres [AG]" "AGInvite" ;
      JoyA.alternative ~label:"Écrire un message" "WritePost" ;
      JoyA.alternative ~label:"Ajouter une photo" "AddPicture" ;
      JoyA.alternative ~label:"Créer un évènemement" "CreateEvent" ;
      JoyA.alternative ~label:"Créer un évènement [AG]" "CreateAG" ;
      JoyA.alternative ~label:"Écrire une annonce" "Broadcast" ;
      JoyA.alternative ~label:"Inviter une organisation" "InviteNetwork" ;
      JoyA.alternative ~label:"S'abonner" "Buy" ;
      JoyA.alternative ~label:"(Après) Créer un autre évènement" "AnotherEvent" ;
    ])) ;
    JoyA.field "summary" ~label:"Résumé"  (JoyA.string ~editor:`area ()) ;
    JoyA.field "archive" ~label:"Archivé" JoyA.bool ;    
    JoyA.field "message" ~label:"Message" (JoyA.string ~editor:`area ()) ;
    JoyA.field "youcan" ~label:"Vous Pouvez" (JoyA.optional (JoyA.string ~editor:`area ())) ;
    JoyA.field "subtitle" ~label:"Accroche"  (JoyA.optional (JoyA.string ~editor:`area ())) ;
    JoyA.field "admin"   ~label:"Admin"
      (JoyA.string ~autocomplete:MPreConfigNames.template ()) ;
    JoyA.field "templates" ~label:"Modèles"
      (JoyA.array (JoyA.string ~autocomplete:MPreConfigNames.template ())) ;
    JoyA.field "features" ~label:"Fonctionnalités" (JoyA.string ~editor:`area ()) ;
    JoyA.field "parent" ~label:"Parent" 
      (JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.vertical ())) ;
    JoyA.field "images" ~label:"Anciennes Photos" (JoyA.array (JoyA.string ())) ;
    JoyA.field "thumbs" ~label:"Photos" (JoyA.array (JoyA.obj [
      JoyA.field "image" ~label:"Photo" (JoyA.string ()) ;
      JoyA.field "text" ~label:"Texte" (JoyA.string ()) ;
    ])) ;
    JoyA.field "url" ~label:"runorg.com/catalog/" (JoyA.optional (JoyA.string ())) ;
    JoyA.field "pricing" ~label:"Pricing" (JoyA.optional (JoyA.string ~editor:`area ())) ;
    JoyA.field "catalog" ~label:"Catalogue" (JoyA.array (JoyA.obj [
      JoyA.field "name" ~label:"Nom" (JoyA.string ~autocomplete:MPreConfigNames.i18n ()) ;
      JoyA.field "order" ~label:"Tri" (JoyA.string ()) ;
      JoyA.field "box" ~label:"Catégorie" (JoyA.variant [
	JoyA.alternative ~label:"Associations" "asso" ;
	JoyA.alternative ~label:"Entreprises" "pro" ;
	JoyA.alternative ~label:"Clubs de Sport" "sport" ;
	JoyA.alternative ~label:"Fédérations" "fed" ;
	JoyA.alternative ~label:"Collectivités" "collec" ;
	JoyA.alternative ~label:"CE" "ce" ;
	JoyA.alternative ~label:"Copropriétés" "syndic" ;
	JoyA.alternative ~label:"Autre" "autre" ;
      ])
    ])) ;
    JoyA.field "wording" ~label:"Formulation" (JoyA.optional (JoyA.string ())) ;
  ]
*)

  type json t = <
    name : string ;
    order : string ;
    pricing : string option ;
    catalog : < name : string ; order : string ; box : string > list ;
    archive : bool ;
    message : string ;
    templates : ITemplate.t list ;
    admin : ITemplate.t ;
    desc : string ;
    summary : string ;
    features : string ;
    parent : IVertical.t option ;
    images : string list ;
    youcan : string option ;
    subtitle : string option ;
    thumbs : < image : string ; text : string > list ;
    url : string option ;
    wording : string option;
    steps : Step.t list 
  >

end)

module AdminView = CouchDB.DocView(struct
  module Key = Fmt.Unit
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "admin"
  let map = "if (doc.t == 'vert') emit(null,null);"
end)

let admin_all _ = 
  let! list = ohm (AdminView.doc_query ()) in
  return (
    List.map begin fun item ->
      IVertical.of_id (item # id),
      `label item # doc # name,
      item # doc # archive
    end list
  )

let admin_get _ id = 
  let! vertical_opt = ohm (MyTable.get id) in
  return (BatOption.map (fun doc -> (object
    method name = doc # name
    method desc = doc # desc
    method order = doc # order
    method archive = doc # archive
    method message = doc # message 
    method admin = doc # admin
    method summary = doc # summary
    method features = doc # features
    method parent = doc # parent
    method images = doc # images
    method thumbs = doc # thumbs
    method url = doc # url
    method pricing = doc # pricing
    method catalog = doc # catalog
    method subtitle = doc # subtitle
    method youcan = doc # youcan
    method wording = doc # wording
    method steps = doc # steps
    method templates = 
      doc # event
    @ doc # album
    @ doc # group
    @ doc # poll
    @ doc # forum
    @ doc # subscription
    @ doc # course
  end)) vertical_opt)

let admin_set admin id data = 
  let! templates = ohm $ Template.admin_all admin in
  let kind_by_id = List.map (fun (id, _, kind) -> id, kind) templates in 
  let has_kind k t = try List.assoc t kind_by_id = k with _ -> false in
  let grab k = List.filter (has_kind k) (data # templates) in

  let obj = object
    method t = `Vertical
    method name = data # name
    method desc = data # desc
    method order = data # order
    method summary = data # summary
    method archive = data # archive
    method message = data # message
    method admin = data # admin
    method pricing = data # pricing
    method thumbs = data # thumbs
    method catalog = data # catalog
    method event = grab `Event
    method group = grab `Group
    method forum = grab `Forum
    method album = grab `Album
    method poll  = grab `Poll
    method subscription = grab `Subscription
    method course = grab `Course
    method features = data # features
    method parent = data # parent
    method images = data # images
    method url = data # url
    method subtitle = data # subtitle
    method youcan = data # youcan
    method wording = data # wording
    method steps = data # steps
  end in 
  
  let! _ = ohm $ MyTable.transaction id (MyTable.insert obj) in
  return ()

