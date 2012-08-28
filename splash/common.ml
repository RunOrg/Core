let mapi f l = 
  let rec aux n = function
    | [] -> []
    | h :: t -> f n h :: aux (succ n) t
  in aux 0 l

let string str = 
  Printf.sprintf "%S" str

let html str = 
  let amp     = Str.regexp "&" in
  let lt      = Str.regexp "<" in
  let parskip = Str.regexp "\n[ \t\n]*\n" in
  let break   = Str.regexp "\n" in
  let str = Str.global_replace amp "&amp;" str in
  let str = Str.global_replace lt  "&lt;"  str in
  let paragraphs = Str.split parskip str in 
  let paragraphs = List.filter (fun s -> s <> "") paragraphs in
  let paragraphs = List.map (Str.global_replace break "<br/>") paragraphs in
  let html = "<p>" ^ String.concat "</p><p>" paragraphs ^ "</p>" in
  string html

let list l = 
  "[" ^ String.concat ";" l ^ "]"

let bool = function true -> "true" | false -> "false"  

let call f l = 
  "(" ^ String.concat " " (f :: l) ^ ")"

let obj l = 
  String.concat " "
    ("(object" 
     :: List.map 
	 (fun (name,expr) -> "method " ^ name ^ " = " ^ expr) l
     @ ["end)"]) 

let opt f = function
  | None -> "None"
  | Some x -> "Some ("^f x^")"

let hr () = "(return $ Html.str " ^ string "<hr/>" ^ ")"

let nil () = "(return $ Html.str \"\")"

let composite format left right = 
  let fmt = match format with `LLR -> "-LLR" | `LR -> "-LR" | `LRR -> "-LRR" in
  call "Asset_Splash_Composite.render" 
    [ obj [ "kind",  string fmt ;
	    "left",  left ;
	    "right", right ] ]

let video ~height ~poster sources = 
  call "Asset_Splash_Video.render" 
    [ obj [ "height", string_of_int height ;
	    "poster", string poster ;
	    "sources", list (List.map (fun (src,mime) -> 
	      obj [ "src", string src ; "mime", string mime ]) sources)
	  ]]

let youtube url = 
  call "Asset_Splash_Youtube.render"
    [ string url ] 
    
let bulletize items = 
  let rec aux i = function
    | [] -> []
    | h :: t -> obj [ "number", string_of_int i ; "text", string h ] :: aux (succ i) t
  in aux 1 items 

let bullets ~title ~subtitle ?(ordered=true) items = 
  call "Asset_Splash_Bullets.render"
    [ obj [ "title",    string title ;
	    "subtitle", string subtitle ;
	    "ordered",  bool ordered ; 
	    "bullets",  list (bulletize items) ]]

let pride ~title ?subtitle ?link text = 
  call "Asset_Splash_Pride.render"
    [ obj [ "title", string title ;
	    "subtitle", ( match subtitle with 
	    | None -> "None"
	    | Some subtitle -> "Some " ^ string subtitle ) ;
	    "text", html text ;
	    "link", (match link with 
	    | None -> "None"
	    | Some (link,text) -> 
		"Some " ^ obj [ "text", string text ; "url", string link ]) 
	  ]]

let price title subtitle text = 
  call "Asset_Splash_Price.render"
    [ obj [ "title",    string title ;
	    "subtitle", string subtitle ;
	    "text",     html   text ]]

let image ?copyright url = 
  call "Asset_Splash_Image.render" 
    [ obj [ "url", string url ;
	    "copyright", (match copyright with 
	    | None -> "None"
	    | Some (link,name) -> 
		"Some " ^ obj [ "url", string link ; "name", string name ])
	  ]] 

let action url text sub =
  call "Asset_Splash_Action.render"
    [ obj [ "url", string url ;
	    "text", string text ;
	    "sub", string sub ] ]

let create kind = 
  action ("/start/"^kind) 
    "Créez votre espace"
    "C'est rapide et gratuit !"

let images urls = 
  call "Asset_Splash_List.render"
    [ list (List.map image urls) ]

let ribbon inner = 
  call "Asset_Splash_Ribbon.render" [ inner ]  

let ribbon_title ?name title = 
  call "Asset_Splash_RibbonTitle.render"
    [ obj [ "name", opt string name ; "title", string title ] ]

let features l = 
  call "Asset_Splash_Features.render" 
    [ list (List.map (fun (title, body) ->
      obj [ "title", string title ; "body", html body ] 
    ) l ) ] 

let facebook () = 
  call "Asset_Splash_Facebook.render" [ "()" ] 

let important title text = 
  call "Asset_Splash_Important.render"
    [ obj [ "title", string title ;
	    "text",  html text ]]  

let marklast f l = 
  let rec aux = function
    | [] -> []
    | [last] -> [f true last] 
    | h :: t -> f false h :: aux t
  in aux l 

let recommend ~title ~subtitle items = 
  call "Asset_Splash_Recommend.render"
    [ obj [ "title", string title ;
	    "subtitle", string subtitle ;
	    "items", list (marklast (fun last (who,org,quote) -> 
	      obj [ "who", string who ;
		    "org", string org ;
		    "last", bool last ;
		    "quote", string quote ]) items)
	  ]]

let offer ~title ~price text inc = 
  call "Asset_Splash_Offer.render"
    [ obj [ "title",    string title ;
	    "text",     html text ;
	    "includes", list (List.map string inc) ;
	    "price",    string price ] ]

let pricing ~foot cols rows = 

  let cols = List.map 
      (fun items -> 
	list (List.map (fun (link,name) -> 
	  obj [ "link", string link ; "name", string name ]) items)
      ) cols 
  and rows = mapi
      (fun i (label, cells) ->
	obj [ "alt", bool (i mod 2 = 0) ;
	      "price", bool (i = 0) ;
	      "label", string label ; 
	      "cells", list (mapi (fun i -> function 
		| `Tick -> obj [ "asso", bool (i=0) ; 
				 "ticked", bool true ; 
				 "text", "None" ; 
				 "link", "None" ]
		| `NoTick -> obj [ "asso", bool(i=0) ;
				   "ticked", bool false ; 
				   "text", "None" ; 
				   "link", "None" ]
		| `Text t -> obj [ "asso", bool (i=0) ;
				   "ticked", bool false ; 
				   "text", "Some" ^ string t ; 
				   "link", "None" ]
		| `Link (l,t) -> obj [ "asso", bool (i=0) ;
				       "ticked", bool false ; 
				       "text", "None" ; 
				       "link", "Some " ^ obj ["url", string l ; "text", string t] ]
	      ) cells) ]
      ) rows
  in
  
  call "Asset_Splash_Pricing.render"
    [ obj [ "columns", list cols ; "lines", list rows ; "foot", string foot ]] 

let backdrop_head ~title ~image ~text ~url ~action = 
  call "Asset_Splash_BackdropHead.render"
    [ obj [ "title",  string title ;
	    "text",   html   text ;
	    "image",  string image ;
	    "action", string action ;
	    "url",    string url ] ]
      
let header id ~title ~text ?trynow menu = 
  id, fun subsection -> 
    ( call "Asset_Splash_Pagehead.render" 
	[ obj [ "title", string title ;
		"text",  html text 
	      ] ] 	
    ) :: begin if (trynow, menu) = (None, []) then [] else 
	
	[ call "Asset_Splash_Submenu.render"
	    [ obj [ "trynow", 
		    (match trynow with 
		      | None -> "None"
		      | Some (name,url) -> 
			"Some " ^ obj [ "name", string name ; 
					"url",  string url ]) ;
		    
		    "items", list (List.map (fun (name,sec,url) -> 
		      obj [ "selected", bool (Some sec = subsection) ;
			    "name",     string name ;
			    "url",      string url ]) menu) ;
		    
		    "lower", "None"
		  ]
	    ]
	]
	  
    end

let multiheader id ~title ~text ?trynow menu = 
  id, fun subsection -> 
    ( call "Asset_Splash_Pagehead.render" 
	[ obj [ "title", string title ;
		"text",  html text 
	      ] ] 	
    ) :: begin if (trynow, menu) = (None, []) then [] else 
	
	[ call "Asset_Splash_Submenu.render"
	    [ obj [ "trynow", 
		    (match trynow with 
		      | None -> "None"
		      | Some (name,url) -> 
			"Some " ^ obj [ "name", string name ; 
					"url",  string url ]) ;
		    
		    "items", list (List.map (fun (name,url,sub) -> 
		      obj [ "selected", bool (Some url = subsection || 
			  List.exists (fun (name,url) -> Some url = subsection) sub) ;
			    "name",     string name ;
			    "url",      string url ]) menu) ;
		    
		    "lower", begin 
		      try 

			let _, _, sub = List.find (fun (_,url,sub) ->
			  Some url = subsection 
			  || List.exists (fun (_,url) -> Some url = subsection) sub 
			) menu in

			if sub = [] then "None" else "Some (" ^ begin
			
			  list (List.map (fun (name,url) ->
			    obj [ "selected", bool (Some url = subsection) ;
				  "name", string name ;
				  "url",  string url ]
			  ) sub)
  
			end ^ ")"
			
		      with _ -> "None"
		    end
		  ]
	    ]
	]
	  
    end
