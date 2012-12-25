(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render_event_line access line eid =
  let! event = ohm_req_or (return None) $ MEvent.view ~actor:(access # actor) eid in
  let! name  = ohm $ MEvent.Get.fullname event in
  return $ Some Html.(concat [
    str "<div>" ;
    esc name ; 
    str "<span>" ;
    esc (string_of_int (line # wall # old_count)) ;
    str " + " ;
    esc (string_of_int (line # wall # new_count)) ;
    str "</span></div>"      
  ])

let render_line access line = 
  match line # owner with 
    | `Event eid -> render_event_line access line eid 

let () = CClient.define UrlClient.Inbox.def_home begin fun access ->

  O.Box.fill begin 

    let! htmls, next = ohm $ MInboxLine.View.list ~count:10 (access # actor) (render_line access) in
    
    return (Html.concat htmls) 

  end
  
end
