(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let status_stats_box ~(ctx:'any CContext.full) ~group =
  O.Box.leaf begin fun input _ -> 

    let gid   = MGroup.Get.id group in

    let! count = ohm $ MMembership.InGroup.count gid in 

    let total = count # count + count # pending in
    let stats = [ 
      `label "stats.status.in"      , count # count ;
      `label "stats.status.pending" , count # pending
    ] in

    return (VStats.render ~total ~stats (ctx # i18n))

  end

let filter_stats kind =
  BatList.filter_map begin fun (json, count) ->
    let label = match kind with 
	
      | `checkbox -> 
	begin
	  try 
	    if Json_type.Browse.bool json 
	    then Some (`label "yes") 
	    else Some (`label "no")
	  with _ -> None
	end
	  
      | `choice l ->
	begin 
	  try
	    let i = Json_type.Browse.int json in
	    Some (`text (BatList.at l i))
	  with _ -> None
	end
	  
    in 
    match label with None -> None | Some label -> Some (label, count)
  end 
        

let field_stats_box ~(ctx:'any CContext.full) ~group ~field ~kind =
  O.Box.leaf begin fun input _ -> 

    let gid   = MGroup.Get.id group in 

    let! count = ohm $ MMembership.InGroup.count gid in 
    let! data  = ohm $ MMembership.Data.count    gid (field # name) in

    let total = count # count in
    let stats = filter_stats kind data in
    return (VStats.render ~total ~stats (ctx # i18n))
  end

let root_box ~(ctx:'any CContext.full) ~group = 
  let fields = MGroup.Fields.get group in

  let tablist = 
    [ 
      CTabs.fixed `Status (`label "stats.status") 
	(lazy (status_stats_box ~ctx ~group)) 
    ] 
    @ BatList.filter_map begin fun field -> 
      let tab kind = 
	Some 
	  (CTabs.fixed (`Field (field # name)) field # label 
	     (lazy (field_stats_box ~ctx ~group ~field ~kind)))
      in
      match field # edit with 
	| `textarea 
	| `longtext
	| `date -> None
	| `pickOne  l 
	| `pickMany l -> tab (`choice (List.map (I18n.translate (ctx # i18n)) l)) 
	| `checkbox   -> tab (`checkbox)
    end fields 
  in
  
  CTabs.vertical
    ~list:tablist
    ~url:(UrlR.build (ctx # instance)) 
    ~default:`Status
    ~seg:CSegs.stats_tabs 
    ~i18n:(ctx # i18n)

