(* © 2013 RunOrg *)

type adlib = string

type infoField   = string * [ `LongText | `Text | `Url | `Date | `Address ]
type infoItem    = adlib option * infoField list
type infoSection = adlib * infoItem list

let infoField src kind = src, kind
let infoItem ?label fields = label, fields
let infoSection label items = label, items

type groupConfig = [`Manual|`None] * [`Viewers|`Registered|`Managers]
type collabConfig = [`Viewers|`Registered|`Managers] * [`Viewers|`Registered|`Managers] 

type join = { 
  j_name  : string ;
  j_label : adlib ;
  j_req   : bool ;
  j_type  : [ `Checkbox | `Textarea | `LongText | `Date | `PickOne of adlib list | `PickMany of adlib list ]
}

let join ~name ~label ?(required=false) typ = {
  j_name  = name ;
  j_label = label ;
  j_req   = required ;
  j_type  = typ
} 

let form ~name ~label ?required typ = join ~name ~label ?required typ

type field = {
  f_label : adlib ;
  f_help  : adlib option ;
  f_mean  : [`Summary | `Picture | `Description | `Date | `Location | `Enddate ] option ;
  f_edit  : [ `Textarea | `LongText | `Picture | `Date ] ;
  f_key   : string ;
  f_req   : bool 
}

let field ~label ?help ?mean ?(required=false) edit key = {
  f_label = label ;
  f_help  = help ;
  f_mean  = mean ; 
  f_req   = required ;
  f_edit  = edit ;
  f_key   = key 
}

type column = { 
  c_label : adlib ;
  c_view  : [ `Text | `Date | `DateTime | `Status | `PickOne | `Checkbox ] ;
  c_eval  : [ `Profile of [ `Zipcode | `Birthdate | `Firstname | `Lastname | `Email ] 
	    | `Self of [ `Status | `Date | `Field of string ] ] 
}

let column ~label ~view eval = {
  c_label = label ;
  c_view  = view ;
  c_eval  = eval
}

type template = string
type template_data = {
  t_id : template ;
  t_old : string option ;
  t_name : adlib ;
  t_desc : adlib option ;
  t_join : join list ;
  t_kind : [ `Group | `Event | `Forum ] ;  
  t_page : infoSection list ;
  t_group  : groupConfig option ;
  t_wall   : collabConfig option ;
  t_folder : collabConfig option ;
  t_album  : collabConfig option ;
  t_fields : field list ;
  t_cols   : column list ;
  t_propg  : string option 
} 

type init = {
  i_tmpl : template ;
  i_name : adlib ;
}

let initial i_key i_tmpl ~name = {
  i_tmpl ; i_name = name 
}

type profileForm = string
type profileForm_data = {
  pf_id : profileForm ; 
  pf_name : adlib ;
  pf_subtitle : adlib option ;
  pf_comment : bool ;
  pf_fields : join list ;
}

type vertical = string
type vertical_data = {
  v_id   : vertical ;
  v_old  : string option ;
  v_name : adlib ;
  v_tmpl : template list ;
  v_arch : bool ;
  v_init : init list ;
  v_pfs  : profileForm list 
}

type catalog = (adlib * (vertical * adlib * (adlib option)) list) list

let the_catalog  = ref []
let profileForms = ref []
let verticals    = ref []
let templates    = ref []
let adlibs       = ref [] 

let adlib key ?(old:string option) (fr:string) = 
  let key = match key.[0] with '0' .. '9' -> "_" ^ key | _ -> key in
  try ignore (List.assoc key !adlibs) ; key
  with Not_found ->  adlibs := (key, (old,fr)) :: !adlibs ; key

let groupConfig ~validation ~read = validation, read
let wallConfig ~read ~post = read, post

let profileForm id ~name ?subtitle ?(comment=false) fields = 
  profileForms := {
    pf_id       = id ;
    pf_name     = adlib ("ProfileForm_"^id^"_Name") name ;
    pf_subtitle = BatOption.map (adlib ("ProfileForm_"^id^"_Subtitle")) subtitle ;
    pf_comment  = comment ;
    pf_fields   = fields ;
  } :: !profileForms ;
  id

let template id ?old ~kind ~name ?desc ?propagate 
    ?(columns=[]) ?(fields=[]) ?(join=[]) ?group ?wall ?folder ?album ?(page=[]) () = 
  templates := {
    t_id     = id  ;
    t_old    = old ;
    t_kind   = kind ;
    t_name   = adlib ("Template_"^id^"_Name") name ;
    t_desc   = BatOption.map (adlib ("Template_"^id^"_Desc")) desc ;
    t_join   = join ;
    t_page   = page ;
    t_group  = group ;
    t_wall   = wall ;
    t_folder = folder ;
    t_album  = album ;
    t_fields = fields ;
    t_cols   = columns ;
    t_propg  = propagate ;
  } :: !templates ;
  id 

let group id ~name ?desc ?columns ?fields ?join () = 
  template id ~kind:`Group ~name ?desc ~propagate:"members" ?columns ?fields ?join 
    ~group:(groupConfig ~validation:`Manual ~read:`Viewers) () 

let event id ~name ?group ?desc ?columns ?fields ?collab ?join () = 
  let group = match group with Some g -> g | None -> groupConfig ~validation:`Manual ~read:`Viewers in 
  let collab = match collab with Some g -> g | None -> wallConfig ~read:`Registered ~post:`Viewers in
  template id ~kind:`Event ~name ?desc ?columns ?fields ~group ?join 
    ~wall:collab ~folder:collab ~album:collab () 

let vertical id ?old ?(archive=false) ~name ?(forms=[]) init tmpl = 
  verticals := {
    v_id    = id ;
    v_old   = old ;
    v_name  = adlib ("Vertical_"^id^"_Name") name ;
    v_tmpl  = tmpl ;
    v_arch  = archive ;
    v_init  = init ;
    v_pfs   = forms ;
  } :: !verticals ;
  id

let template_by_id id = 
  try Some (List.find (fun t -> t.t_id = id) (!templates))
  with _ -> None

let inCatalog v name forwho = (v,name,forwho)
let subCatalog ~name list =  (name,list)
let catalog (list : catalog) = the_catalog := list
