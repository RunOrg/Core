(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlClientHelper
open UrlR
  
let post ()  = ( object (self) 
  inherit rest "r/wall/post"
  method build inst user feed react = 
    self # rest inst [
      IFeed.to_string feed ;
      IFeed.Deduce.make_write_token user feed react 
    ]
end )
  
let post_poll () = ( object (self) 
  inherit rest "r/wall/poll/post"
  method build inst user poll = 
    self # rest inst [
      IPoll.to_string poll ;
      IPoll.Deduce.make_answer_token user poll 
    ]
end )
  
let swap_view_poll () = ( object (self) 
  inherit rest "r/wall/poll/view"
  method build inst user poll = 
    self # rest inst [
      IPoll.to_string poll ;
      IPoll.Deduce.make_answer_token user poll
    ]
end )
  
let swap_form_poll () = ( object (self) 
  inherit rest "r/wall/poll/form"
  method build inst user poll = 
    self # rest inst [
      IPoll.to_string poll ;
      IPoll.Deduce.make_answer_token user poll
    ]
end )

let poll_details () = ( object (self) 
  inherit rest "r/wall/poll/details"
  method build inst user poll which = 
    self # rest inst [
      IPoll.to_string poll ;
      IPoll.Deduce.make_answer_token user poll ;
      string_of_int which 
    ]
end )
  
let more ()  = ( object (self)
  inherit rest "r/wall/more"
  method build inst user feed react time = 
    self # rest inst [
      string_of_float time ;
      IFeed.to_string feed ;
      IFeed.Deduce.make_read_token user feed react ;
      if react then "react" else "" 
    ]
end )
  
let more_replies ()  = ( object (self)
  inherit rest "r/wall/more/reply"
  method build inst user item = 
    self # rest inst [
      IItem.to_string item ;
      IItem.Deduce.make_read_token user item 
    ]
end )
  
let reply () = ( object (self) 
  inherit rest "r/wall/reply"
  method build inst id user item = 
    self # rest inst [
      Id.str id ;
      IItem.to_string item ;
      IItem.Deduce.make_reply_token user item
    ]
end)
  
let remove () = ( object (self)
  inherit rest "r/item/remove"
  method build inst user item = 
    self # rest inst [
      IItem.to_string item ;
      IItem.Deduce.make_remove_token user item
    ]
end)

let moderate = object (self)
  inherit rest "r/wall/moderate"
  method build inst (feed :[`Admin] IFeed.id) (item:IItem.t) = 
    self # rest inst [ 
      IFeed.to_string feed ;
      IItem.to_string item
    ]
end
  
let post_reply () = ( object (self) 
  inherit rest "r/wall/post/reply"
  method build inst id user item = 
    self # rest inst [
      Id.str id ;
      IItem.to_string item ;
      IItem.Deduce.make_reply_token user item
    ]
end)
  
let like_item () = ( object (self)
  inherit rest "r/wall/like/item"
  method build inst user item = 
    self # rest inst [
      IItem.to_string item ;
      IItem.Deduce.make_like_token user item
    ]
end) 
  
