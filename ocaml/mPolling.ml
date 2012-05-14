(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Source = struct
  module T = struct
    type json t = 
	RSS of string 
  end
  include T
  include Fmt.Extend(T)
end

module RSST = struct
  module Float = Fmt.Float
  module Clean = OhmSanitizeHtml.Clean
  module T = struct
    type json t = {
      link  "l" : string ;
      title "s" : string ;
      time  "t" : Float.t ;
      body  "b" : Clean.t
    }
  end
  include T
  include Fmt.Extend(T)
end

module Content = struct
  module T = struct
    type json t = 
	RSS of RSST.t list
  end
  include T 
  include Fmt.Extend(T)
end

(* Dealing with RSS ----------------------------------------------------------- *)

let poll_rss url = 
  let xml = Http_client.Convenience.http_get url in
  let digest = Digest.string xml |> Digest.to_hex in 
  let lazy_content = lazy begin 
    let rss = OhmParseRss.parse xml in
    let items = BatList.filter_map begin fun item ->
      let! title = req_or None item.OhmParseRss.Item.title in 
      let! date  = req_or None item.OhmParseRss.Item.pubdate in
      let! desc  = req_or None item.OhmParseRss.Item.description in 
      let! link  = req_or None item.OhmParseRss.Item.link in
      let  body =
	OhmSanitizeHtml.parse_string desc 
      |> OhmSanitizeHtml.cut ~max_lines:13 ~max_chars:10000 
      in
      let time = Netdate.parse date |> Netdate.since_epoch in
      Some RSST.({ link ; time ; title ; body }) 
    end rss in 
    Content.RSS items 
  end in 
  Some (digest, lazy_content) 

(* Actual configuration file for using the ozCouchPollUrl module -------------- *)

module Config = struct

  module Source    = Source
  module Content   = Content
  module PollDB    = CouchDB.Convenience.Database(struct let db = O.db "polling-info" end)
  module ContentDB = CouchDB.Convenience.Database(struct let db = O.db "polling-content" end) 

  type ctx = O.ctx
  let couchDB ctx = (ctx :> CouchDB.ctx) 

  let poll = function 
    | Source.RSS url -> poll_rss url 

end

module Poller = OhmCouchPollUrl.Make(Config) 

let () = O.async # periodic 1 (Poller.process 60.0)

(* Forward calls to the poller module. ---------------------------------------- *)

module RSS = struct

  module Signals = struct
    let update_call, update = Sig.make $ 
      Run.list_fold (fun a b -> Run.map (fun a -> a || b) a) false
  end

  type t = RSST.t = {
    link  : string ;
    title : string ;
    time  : float ;
    body  : OhmSanitizeHtml.Clean.t
  }

  let poll url = 
    let! id = ohm $ Poller.poll ~delay:3600.0 (Source.RSS url) in
    return $ IPolling.RSS.of_id id
      
  let disable id = 
    Poller.disable $ IPolling.RSS.to_id id
      
  let get id = 
    let  id = IPolling.RSS.to_id id in
    let! content = ohm_req_or (return []) $ Poller.get id in 
    match content with 
      | Content.RSS data -> return $ data
	
end

(* Reacting to signals from the polling module. ------------------------------- *)

let _ = 
  Sig.listen Poller.Signals.change begin fun (id, source, content) ->
    Util.log "Poller change : %s : %s" (Id.str id)
      (Source.to_json_string source) ;
    match content with 
      | Content.RSS rss -> RSS.Signals.update_call (IPolling.RSS.of_id id, rss)
  end

