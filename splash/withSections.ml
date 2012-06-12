open Common 

let page_title section = 
  let show_section (id,name,url) = obj [
    "name", string name ;
    "url",  string url ;
    "selected", bool (Some id = section)
  ] in 
  
  call "Asset_Splash_Title.render" 
    [ obj [ "home", string "/" ;
	    "products", list (List.map show_section Sections.sections) 
	  ] ] 
    
let page_head ?head ?subsection () =
  match head with None -> [] | Some id -> 
    try 
      let header = List.assoc id Headers.headers in
      header subsection 
    with Not_found -> failwith ("Header #"^id^" does not exist")

let page_foot () = 
  call "Asset_Splash_Footer.render" 
    [ list (List.map (fun (name,url) -> 
      obj [ "name", string name ; 
	    "url",  string url ] ) Footer.footer) ]

let page url title ?section ?head ?subsection layers = 
  
  let render = list
    ( [page_title section] 
      @ page_head ?head ?subsection ()
      @ layers 
      @ [ page_foot () ] )
  in 
  
  let url = 
    if url.[0] = '/' then String.sub url 1 (String.length url - 1) 
    else url 
  in

  "let _ = " ^
  (call "O.register" 
     [ "O.core" ;
       string url ;
       "Ohm.Action.Args.none" ;
       "(fun _ -> " 
       ^ call "CPageLayout.splash" [ string title ; render ] 
       ^ ")"
     ])
  ^ " ;; "

let included = 
  "let header : Ohm.Html.writer O.run = " ^ page_title None
  ^ " and footer : Ohm.Html.writer O.run = " ^ page_foot () 
