(* © 2012 RunOrg *)

type t  = Ohm.JsCode.t
type id = Ohm.Id.t
type view = Ohm.View.Context.box Ohm.View.t
type jsont = Json_type.t

open Ohm
open Ohm.JsCode

module Dialog = struct

  let create ?(options=[]) html title = 
    let html, js = View.extract html in  
    make
      ~name:"runorg.dialog"
      ~args:[ Json_type.Build.string html ;
	      Json_type.Build.string title ;
	      JsBase.to_json (seq [JsBase.staticInit ; js]) ;
	      Json_type.Build.objekt options ]

  let close = 
    make 
      ~name:"runorg.closeDialog"
      ~args:[]
      
end

let maxFieldLength length id = 
  make
    ~name:"runorg.maxFieldLength"
    ~args:[ Id.to_json id; 
	    Json_type.Build.int length ]

let picUploader ~id ~url_get ~url_put ~title = 
  make
    ~name:"runorg.picUploader"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string url_get ;
	    Json_type.Build.string url_put ;
	    Json_type.Build.string title ]

let datepicker selector ~lang ~ancient = 
  make 
    ~name:"runorg.datepicker"
    ~args:[ Json_type.Build.string selector ;
	    Json_type.Build.string (match lang with `Fr -> "fr") ;
	    Json_type.Build.bool ancient ]

module Start = struct

  let refresh view_opt = 
    let args = match view_opt with 
      | Some html -> let html, js = View.extract html in  
		     [ Json_type.Bool true ;
		       Json_type.Build.string html ;
		       JsBase.to_json js ;		       
		     ]
      | None      -> [ Json_type.Bool false ] 
    in
    make 
      ~name:"runorg.start.refresh"
      ~args

end

(* Old, unclean code ------------------------------------------------------------------------ *)

let init = 
  make
    ~name:"runorg.init" 
    ~args:[]

let refreshDelayed = 
  make
    ~name:"runorg.refreshDelayed"
    ~args:[]

let assoKey url = 
  make
    ~name:"runorg.assoKey"
    ~args:[ Json_type.String url ]

let jQuery sel func args = 
  make
    ~name:"runorg.jQuery"
    ~args:( Json_type.Build.string sel 
	    :: Json_type.Build.string func
	    :: args )

let onLoginPage cookie = 
  make 
    ~name:"runorg.onLoginPage"
    ~args:[ Json_type.Build.string cookie ]

let onClick selector code = 
  make
    ~name:"runorg.onClick" 
    ~args:[ Json_type.Build.string selector ;
	    JsBase.to_json code ]

let unloggedRedirect ~login = 
  make
    ~name:"runorg.unloggedRedirect"
    ~args:[ Json_type.Build.string login ]

let editsJoin ~jid ~url ~sel= 
  make 
    ~name:"runorg.editsJoin"
    ~args:[ Id.to_json jid ;
	    Json_type.Build.string url ;
	    Id.to_json sel ]

let appendList id html =
  let html, js = View.extract html in  
  make
    ~name:"runorg.appendList"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ]

let appendUniqueList id html uid =
  let html, js = View.extract html in  
  make
    ~name:"runorg.appendUniqueList"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ;
	    Id.to_json uid ]


let replaceInList id html =
  let html, js = View.extract html in  
  make
    ~name:"runorg.replaceInList"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ]

let sendSelected url = 
  make
    ~name:"runorg.sendSelected"
    ~args:[ Json_type.Build.string url ]

let moreReplies url = 
  make
    ~name:"runorg.moreReplies"
    ~args:[ Json_type.Build.string url ]

let wait url code = 
  make 
    ~name:"runorg.wait"
    ~args:[ Json_type.Build.string url ;
	    JsBase.to_json code ]

let sortable id idto placeholder = 
  make 
    ~name:"runorg.sortable"
    ~args:[ Id.to_json id ;
	    Id.to_json idto ;
	    Json_type.Build.string placeholder ]

let message html = 
  let html, js = View.extract html in
  make 
    ~name:"runorg.message"
    ~args:[ Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ]

let redirect url = 
  make
    ~name:"runorg.redirect" 
    ~args:[ Json_type.Build.string url ]

let hideLabel id = 
  make
    ~name:"runorg.hideLabel"
    ~args:[ Id.to_json id ]

let toggleParent id sel cls = 
  make
    ~name:"runorg.toggleParent"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string sel ;
	    Json_type.Build.string cls ]

let removeParent sel = 
  make
    ~name:"runorg.removeParent"
    ~args:[ Json_type.Build.string sel ]

 
let onChange selector code = 
  make
    ~name:"runorg.onChange"
    ~args:[ Json_type.Build.string selector ;
	    JsBase.to_json code ]

let setField ?(overwrite=false) id value =
  make
    ~name:"runorg.setField"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string value ;
	    Json_type.Build.bool overwrite ]
	    
let setFieldAsync ?(overwrite=false) id source = 
  make
    ~name:"runorg.setField"
    ~args:[ Id.to_json id ;
	    JsBase.source_to_json source ;
	    Json_type.Build.bool overwrite ]

let askServer url extract data = 
  JsBase.source
    ~name:"runorg.askServer"
    ~args:[ Json_type.Build.string url ;
	    Json_type.Build.objekt
	      (List.map (fun (n,v) -> n, Id.to_json v) extract) ;
	    Json_type.Build.objekt data
	  ]

let wallPost id html = 
  let html, js = View.extract html in  
  make
    ~name:"runorg.wallPost"
    ~args:[ Id.to_json id ; 
	    Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ]  

let like url = 
  make 
    ~name:"runorg.like"
    ~args:[ Json_type.Build.string url ]

let refresh = 
  make 
    ~name:"runorg.refresh"
    ~args:[]

let runFromServer ?(disable=false) ?args url = 
  make
    ~name:"runorg.runFromServer"
    ~args:[ Json_type.Build.string url ;
	    (match args with Some json -> json | None -> Json_type.Build.objekt [] ) ;
	    Json_type.Build.bool disable ]

let appendReply id html = 
  let html, js = View.extract html in
  make
    ~name:"runorg.appendReply"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ]

let replaceWith sel html = 
  let html, js = View.extract html in
  make
    ~name:"runorg.replaceWith"
    ~args:[ Json_type.Build.string sel ;
	    Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ]

let replaceOtherWith sel html = 
  let html, js = View.extract html in
  make
    ~name:"runorg.replaceOtherWith"
    ~args:[ Json_type.Build.string sel ;
	    Json_type.Build.string html ;
	    JsBase.to_json (seq [JsBase.staticInit ; js]) ]

let assignPicked idfrom idto = 
  make 
    ~name:"runorg.assignPicked"
    ~args:[ Id.to_json idfrom ;
	    Id.to_json idto ]

let sendPicked id url = 
  make 
    ~name:"runorg.sendPicked"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string url ]

let sendList id url = 
  make 
    ~name:"runorg.sendList"
    ~args:[ Id.to_json id ;
	    Json_type.Build.string url ]
	    
let picker id = 
  make
    ~name:"runorg.picker"
    ~args:[ Id.to_json id ]

let verticalPicker id = 
  make
    ~name:"runorg.verticalPicker"
    ~args:[ Id.to_json id ]

let lazyPick url sel = 
  make
    ~name:"runorg.lazyPick"
    ~args:[ Json_type.Build.string url ;
	    Json_type.Build.string sel ]

let lazyNext url = 
  make 
    ~name:"runorg.lazyNext"
    ~args:[ Json_type.Build.string url ]

module Html = struct

  let return html = 
    let html, js = View.extract html in
    [
      "html", Json_type.Build.string html ;
      "code", JsBase.to_json (seq [JsBase.staticInit ; js ]) 
    ]	

end

module More = struct
    
  let fetch ?(args=[]) url = 
    make
      ~name:"runorg.fetchMore"
      ~args:[ Json_type.Build.string url ;
	      Json_type.Build.objekt args ]

  let return = Html.return

end

let setTrigger name code = 
  make
    ~name:"runorg.setTrigger"
    ~args:[ Json_type.Build.string name ;
	    JsBase.to_json code ]

let autocomplete id idto url =
  make
    ~name:"runorg.autocomplete"
    ~args:[ Id.to_json id ;
	    Id.to_json idto ;
	    Json_type.Build.string url ]

let runTrigger name = 
  make 
    ~name:"runorg.runTrigger"
    ~args:[ Json_type.Build.string name ]

let panic = 
  make 
    ~name:"runorg.panic"
    ~args:[]

let notify ~id ~unread ~total = 
  make
    ~name:"runorg.notify"
    ~args:[ 
      Json_type.Build.string 
	(match id with `message -> "message-count" | `news -> "news-count") ;
      Json_type.Build.int unread ;
      Json_type.Build.int total 
    ]

let return code = 
  Json_type.Build.objekt ["code", JsBase.to_json code]

(*
let showProfile path profile = 
  let html = Breathe.Profiling.to_table profile in 
  make
    ~name:"runorg.showProfile"
    ~args:[ Json_type.Build.string path ;
	    Json_type.Build.string html ]
*)

module Grid = struct

  type column = Json_type.t

  let column ?index ?width ?render ?label ?sort () = 
    let list = match index with None -> [] | Some i -> ["i",Json_type.Build.int i] in
    let list = match width with None -> list | Some w -> ("w",Json_type.Build.int w)::list in
    let list = match render with None -> list | Some r -> ("f",JsBase.render_to_json r)::list in
    let list = match label with None -> list | Some l -> ("n",Json_type.Build.string l)::list in
    let list = match sort with Some true -> ("s",Json_type.Build.bool true)::list | _ -> list in
    Json_type.Build.objekt list

  let grid ~id ~url ~cols ~edit = 
    make 
      ~name:"runorg.joinGrid"
      ~args:[ Id.to_json id ;
	      Json_type.Build.string url ;
	      Json_type.Build.array cols ;
	      Json_type.Build.string edit ]

  let return ~rows ~next = 
    [
      "rows", Json_type.Build.list Json_type.Build.array rows ;
      "next", Json_type.Build.optional (fun (key,id) ->
	Json_type.Build.array [ 
	  Json_type.Build.string (Json_io.string_of_json ~recursive:true ~compact:true key) ;
	  Id.to_json id ]
      ) next;
    ]


end

module Admin = struct

  let joy id edit autocomplete = 
    let autocomplete = 
      List.map
	(fun (namespace, names) -> 
	  namespace, Json_type.Build.list Json_type.Build.string names) 
	(autocomplete)
    in
    JsCode.make
      ~name:"admin.joy"
      ~args:[ Id.to_json id ;
	      JoyA.Node.to_json edit ;
	      Json_type.Build.objekt autocomplete ]

end
