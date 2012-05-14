(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Buy = struct

  module Fields = struct

    type config = unit
    let  config = ()

    include Fmt.Make(struct
      type json t = [ `Name | `Address | `Main | `Memory ]
    end)

    let fields = [ `Name ; `Address ; `Main ; `Memory ]

    let details = function 

      | `Name      -> Form.text     ~name:"name" ~label:"client.buy.name"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 80 id)
      | `Address   -> Form.textarea ~name:"address" ~label:"client.buy.address"
	|> Form.add_js (fun id _ -> Js.maxFieldLength 300 id) 

      | `Main   -> Form.select ~name:"main" ~label:"client.buy.main"
	~values:(fun _ -> MRunOrg.Offer.main)
	~renderer:begin fun i18n (id,offer) ->
	  let label = 	    
	    I18n.get_param i18n "client.buy.main.detail" [
	      View.str (string_of_int (offer # seats)) ;
	      View.str (MRunOrg.Offer.print_memory (offer # memory)) ;
	      View.str (MRunOrg.Offer.print_year_price (offer # daily))
	    ]
	  in
	  IRunOrg.Offer.to_json (IRunOrg.Offer.decay id), label
	end

      | `Memory -> Form.select ~name:"memory" ~label:"client.buy.memory"
	~values:(fun _ -> None :: List.map (fun x -> Some x) MRunOrg.Offer.memory)
	~renderer:begin fun i18n offer ->
	  match offer with 
	    | None -> Json_type.String "none", I18n.get i18n (`label "client.buy.memory.none") 
	    | Some (id, offer) ->
	      let label = 
		I18n.get_param i18n "client.buy.memory.detail" [
		  View.str (MRunOrg.Offer.print_memory (offer # memory)) ;
		  View.str (MRunOrg.Offer.print_year_price (offer # daily))
		]
	      in
	      IRunOrg.Offer.to_json (IRunOrg.Offer.decay id), label
	end
	
    let hash = Form.prefixed_name_as_hash "buy" details

  end

  module Form = Form.Make(Fields)

end
