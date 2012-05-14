(* © 2012 RunOrg *)
  
open Ohm
open BatPervasives
open Ohm.Universal

let short ~ctx ~entity = 
  O.Box.reaction "short" begin fun _ bctx _ response -> 

    let! votes = ohm $ MVote.by_owner ctx (`entity entity) in
    let! votes = ohm $ Run.list_filter MVote.Can.read votes in
    let! stats = ohm $ Run.list_collect begin fun vote -> 
      let! short   = ohm $ MVote.Stats.get_short vote in
      let  percent = if short # count = 0 then 0. else 100. /. float_of_int (short # count) in
      return begin 
	[ [ I18n.translate (ctx # i18n) (MVote.Question.get vote) # question ] ]
	@ List.map (fun (answer,count) -> 
	  [ I18n.translate (ctx # i18n) answer ;
	    string_of_int count ;
	    Printf.sprintf ("%.2f%%") (float_of_int count *. percent) 
    	      |> (fun str -> BatString.replace ~str ~sub:"." ~by:",") |> snd ]) (short # votes)
	@ [ [ I18n.translate (ctx # i18n) (`label "vote.voters.total") ; 
	      string_of_int (short # count) ] ;
	    [ "" ] ]
      end
    end votes in

    let csv = OhmCsv.to_csv [] stats in

    return $ O.Action.file 
      ~file:"votes.csv" ~mime:OhmCsv.mime ~data:csv response
     
  end 

let long ~ctx ~entity = 
  O.Box.reaction "long" begin fun _ bctx _ response -> 

    let! votes = ohm $ MVote.by_owner ctx (`entity entity) in
    let! votes = ohm $ Run.list_filter MVote.Can.read votes in
    let! stats = ohm $ Run.list_collect begin fun vote -> 

      let! long    = ohm $ MVote.Stats.get_long vote in
      let! ballots = ohm $ Run.list_map (fun (aid,votes) -> 
	let! details = ohm $ MAvatar.details aid in
	return (CName.get (ctx # i18n) details, votes)
      ) long in

      let anon    = MVote.Get.anonymous vote in
      let answers = (MVote.Question.get vote) # answers in

      return begin 

	[ I18n.translate (ctx # i18n) (MVote.Question.get vote) # question 
	  :: (
	    if anon then 
	      [ I18n.translate (ctx # i18n) (`label "vote.anonymous") ]
	    else
	      List.map (I18n.translate (ctx # i18n)) answers
	  ) ]

	@ List.map (fun (name,votes) -> 
	  name 
	  :: (
	    if anon then [] else 
	      BatList.mapi (fun i _ -> if List.mem i votes then "1" else "") answers
	  )
	) ballots 
	  
	@ [ [ "" ] ]
	  
      end
    end votes in

    let csv = OhmCsv.to_csv [] stats in

    return $ O.Action.file 
      ~file:"votes.csv" ~mime:OhmCsv.mime ~data:csv response
     
  end 

