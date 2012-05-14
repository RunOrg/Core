let () = Printexc.record_backtrace true 

module Path = struct

  let concat a b = if b = "." then a else Filename.concat a b

  let root = concat (Sys.getcwd ())
  let gen  = concat (root "gen")
    
  let view_input  = root "views"
  let view_output = gen  "views"

  let css_input   = root "css"
  let css_output  = concat (gen "css")

  let js_input    = root "coffee"
  let js_output   = concat (gen "js")

end

(* A handful of utility functions *)

let rec remove_file path = 
  try Array.iter 
	(fun filename ->
	  let path = Filename.concat path filename in
	  let stat = Unix.stat path in
	  match stat.Unix.st_kind with
	    | Unix.S_DIR -> remove_file path ; Unix.rmdir path
	    | _          -> Unix.unlink path)
	(Sys.readdir path)
  with _ -> ()

let file_get_content_stream path buffer = 
  let output = BatIO.output_buffer buffer in
  BatFile.with_file_in path (fun input -> BatIO.copy input output) 

let file_get_content path = 
  BatFile.with_file_in path (BatIO.read_all) 

let rec file_ensure ?(directory=false) path = 

  let kind = 
    try let stat = Unix.stat path in Some stat.Unix.st_kind
    with _ -> None
  in

  if kind <> Some (if directory then Unix.S_DIR else Unix.S_REG) then begin
    file_ensure ~directory:true (Filename.dirname path) ;
    if directory then Unix.mkdir path 0o700  
  end    

let file_put_content_stream path buffer = 
  file_ensure path ;
  BatFile.with_file_out path (fun output -> BatIO.write_buf output buffer) 

let file_put_content path string =
  file_ensure path ;
  BatFile.with_file_out path (fun output -> BatIO.nwrite output string) 

let list_all path extension f = 
  let ext = "." ^ extension in 
  Array.iter 
    (fun filename -> if BatString.ends_with filename ext then f (Filename.concat path filename))
    (Sys.readdir path)

let list_all_recurse path outpath extension f = 
  let ext = "." ^ extension in 
  let rec process path outpath = 
    Array.iter 
      (fun filename ->
	if BatString.ends_with filename ext then f (outpath filename) (Filename.concat path filename) 
	else let path = Filename.concat path filename and outpath = Path.concat (outpath filename) in
	     let stat = Unix.stat path in
	     if stat.Unix.st_kind = Unix.S_DIR && filename <> ".svn" then process path outpath)
      (Sys.readdir path)
  in
  process path outpath

let rec replace_all str sub by = 
  let replaced, str = BatString.replace str sub by in 
  if replaced then replace_all str sub by else str

(* Remove all output targets first *)

let _ = 
  List.iter remove_file [ Path.view_output ; Path.css_output "." ; Path.js_output "." ]

(* Global variables that will store the CSS and JS extracted from all sources *)

module Output = struct
    
  let less   = Buffer.create 4096
  let coffee = Buffer.create 4096

end

module Coffee = struct

  let id = ref 0 

  let add_coffeescript params source = 
    incr id ;
    Buffer.add_string Output.coffee (Printf.sprintf "@j%d=(%s)->\n" !id (String.concat "," params)) ;
    List.iter
      (fun line -> 
	Buffer.add_string Output.coffee "  " ; 
	Buffer.add_string Output.coffee line ;
	Buffer.add_char   Output.coffee '\n' )
      (BatString.nsplit source "\n") ;
    !id 

  let script_begin  = "<script type=\"coffeescript\" params=\""
  let script_middle = "\">"
  let script_end    = "</script>"

  let process file = 
    let output = Buffer.create (String.length file) in
    let rec process start_i = 
      try let begin_i = BatString.find_from file start_i script_begin in   
	  if begin_i <> start_i then begin 
	    Buffer.add_substring output file start_i (begin_i - start_i) 
	  end ;
	  try let middle_i = BatString.find_from file begin_i  script_middle in 
	      let end_i    = BatString.find_from file middle_i script_end in 
	      
	      let params_i      = begin_i + String.length script_begin in
	      let params_string = String.sub file params_i (middle_i - params_i) in
	      let params        = List.map BatString.strip (BatString.nsplit params_string ",") in

	      let script_i      = middle_i + String.length script_middle in
	      let script_string = String.sub file script_i (end_i - script_i) in

	      let id = add_coffeescript params script_string in 

	      Buffer.add_string output (Printf.sprintf "{j:j%s}" (String.concat ":" (string_of_int id :: params))) ;
	      
	      process (end_i + String.length script_end) 

	  with _ -> (* middle_i or end_i not found *)
	    Buffer.add_char output file.[begin_i] ; 
	    process (begin_i + 1) 
      with _ -> (* begin_i not found *)
	if start_i < String.length file then begin 	  
	  Buffer.add_substring output file start_i (String.length file - start_i) ;
	end
    in
    try let start_i = BatString.find file script_begin in 
	Buffer.add_substring output file 0 start_i ;
	process start_i ;
	Buffer.contents output
    with Not_found -> file

  let _ = Buffer.add_string Output.coffee "$$ = @\n" 

end

module Less = struct

  let style_begin = "<style type=\"less\">"
  let style_end   = "</style>"

  let process file = 
    let output = Buffer.create (String.length file) in
    let rec process start_i = 
      try let begin_i = BatString.find_from file start_i style_begin in   
	  if start_i <> begin_i then 
	    Buffer.add_substring output file start_i (begin_i - start_i) ;
	  try let end_i   = BatString.find_from file begin_i style_end in 	      
	      let style_i = begin_i + String.length style_begin in
	      
	      Buffer.add_substring Output.less file style_i (end_i - style_i) ;

	      process (end_i + String.length style_end) 

	  with Not_found -> (* end_i not found *)
	    Buffer.add_char output file.[begin_i] ; 
	    process (begin_i + 1) 
      with _ -> (* begin_i not found *)
	if start_i < String.length file then 
	  Buffer.add_substring output file start_i (String.length file - start_i)
    in
    try let start_i = BatString.find file style_begin in 
	Buffer.add_substring output file 0 start_i ;
	process start_i ;
	Buffer.contents output
    with _ -> file

end

let process () = 

  (* STEP 1 : preload the LESS CSS include files *)
  
  let _ = 
    list_all (Filename.concat Path.css_input "include") "css" (fun path -> file_get_content_stream path Output.less) 
  in

  (* STEP 2 : read the views *)
  
  let files_read = ref 0 in

  let _ = 
    list_all_recurse Path.view_input (Path.concat Path.view_output) "htm"
      (fun output_path input_path ->
	incr files_read ;
	let id = "file" ^ string_of_int !files_read in 
	let contents = file_get_content input_path in
	let contents = replace_all contents "###" id in 
	let contents = Less.process (Coffee.process contents) in
	file_put_content output_path contents)
  in

  (* STEP 3 : concatenate additional LESS CSS files and output everything. *)
  
  let _ =   
    list_all Path.css_input "css" (fun path -> file_get_content_stream path Output.less) ;
    
    let less_path = Path.css_output "full.less" and css_path = Path.css_output "full.css" in
    file_put_content_stream less_path Output.less ;
    
    let result = Sys.command ("lessc -x " ^ Filename.quote less_path ^ " > " ^ Filename.quote css_path) in
    if 0 <> result then failwith ("Compilation returned code " ^ string_of_int result) ;
    
    let css = file_get_content css_path in 
    let css = replace_all css ";}" "}" in
    let css = replace_all css "\n" "" in
    file_put_content css_path css
  in

  (* STEP 4 : concatenate additional Coffeescript files *)

  let _ = 
    
    list_all Path.js_input "coffee" (fun path -> 
      file_get_content_stream path Output.coffee ; 
      Buffer.add_char Output.coffee '\n') ;
    
    file_put_content_stream (Path.js_output "full.coffee") Output.coffee ;
    
    let result = Sys.command ("coffee --compile " ^ Filename.quote (Path.js_output ".")) in
    if 0 <> result then failwith ("Compilation returned code " ^ string_of_int result) 

  in

  ()

let _ = 
  try process () with exn -> 
    print_endline (Printexc.to_string exn) ;
    Printexc.print_backtrace stdout 
