(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

module Receive = struct

  module Fields = struct

    type config = unit
    let  config = ()

    include Fmt.Make(struct
      type json t = 
	[ `Autologin
	| `Block of [ `myMembership 
		    | `message
		    | `likeItem
		    | `commentItem
		    | `subscription
		    | `event
		    | `forum
		    | `album
		    | `group
		    | `poll
		    | `course
		    | `item
		    | `pending
		    | `digest
		    | `networkInvite ]
	]
    end)

    let blockable = 
      [ `myMembership ;		   
	`likeItem ;
	`commentItem ;
	`subscription ;
	`event ;
	`forum ;
	`album ;
	`group ;
	`poll ;
	`course ;
	`message ;
	`item ;
	`pending ;
	`digest ;
	`networkInvite 
      ]

    let fields = 
      `Autologin :: List.map (fun b -> `Block b) blockable
		 
    let details = function
      | `Block field -> 

	let name = match field with 
	  | `myMembership  -> "myMembership"
	  | `likeItem      -> "likeItem"
	  | `commentItem   -> "commentItem"
	  | `subscription  -> "subscription"
	  | `event         -> "event"
	  | `forum         -> "forum"
	  | `album         -> "album"
	  | `group         -> "group"
	  | `poll          -> "poll"
	  | `course        -> "course"
	  | `message       -> "message"
	  | `item          -> "item"
	  | `pending       -> "pending"
	  | `digest        -> "digest"
	  | `networkInvite -> "networkInvite"
	in
	Form.checkbox ~name:name ~label:("notification.receive-form."^name)

      | `Autologin ->
	Form.checkbox ~name:"autologin" ~label:"notification.autologin"

    let hash = Form.prefixed_name_as_hash "receive" details
  end

  module Form = Form.Make(Fields)

end
