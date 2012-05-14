(* © 2012 RunOrg *)

module Home : Ohm.Template.HTML with type t = string * string

module ReplyForm : Ohm.Template.HTML with type t = <
    url  : string ;
    init : FWall.Reply.Form.t
  > ;;

module ReplyForbidden : Ohm.Template.HTML with type t = unit

(* Single reply ---------------------------------------------------------------------------- *)

class reply : 
     pic:string
  -> name:string 
  -> role:string option
  -> url:string
  -> text:string
  -> date:float
  -> object
       
  method pic   : string
  method url   : string
  method name  : string
  method role  : string
  method text  : string
  method abuse : string
  method date  : float

end

module Reply : Ohm.Template.HTML with type t = reply

(* Main wall rendering ----------------------------------------------------------- *)

class item :
     id:Ohm.Id.t
  -> pic:string 
  -> url:string
  -> name:string
  -> role:string option
  -> text:string
  -> reply:string
  -> like:string
  -> likes:int 
  -> liked:bool
  -> react:bool
  -> replies:reply list
  -> remove:string option
  -> more:string option
  -> attach:Ohm.View.html
  -> kind:[`none|`image|`poll|`doc of MFile.Extension.t]
  -> date:float 
  -> object
      
    method id      : string
    method url     : string
    method pic     : string
    method name    : string
    method role    : string
    method text    : string
    method like    : < like : string ; liked : bool ; likes : int > option 
    method reply   : string option 
    method remove  : string option 
    method replies : reply list
    method abuse   : string
    method date    : float
    method attach  : Ohm.View.html
    method more    : string option
    method icon    : string
end

module Item : Ohm.Template.HTML with type t = item

class chat_item : 
     id:Ohm.Id.t
  -> date:float
  -> participants:int
  -> lines:int
  -> url:string
  -> avatars:(string * string) list
  -> label:Ohm.I18n.text
  -> object

    method id           : string
    method participants : int
    method lines        : int
    method date         : float
    method url          : string
    method avatars      : (string * string) list
    method label        : Ohm.I18n.text

end

module ChatItem : Ohm.Template.HTML with type t = chat_item

class chat_request_item : 
     id:Ohm.Id.t
  -> date:float
  -> topic:string
  -> chat:string
  -> name:string
  -> picture:string
  -> url:string 
  -> object

    method id      : string
    method date    : float
    method picture : string
    method chat    : string
    method url     : string
    method name    : string
    method topic   : string

end

module ChatRequestItem : Ohm.Template.HTML with type t = chat_request_item

module N : Ohm.Template.HTML with type t = unit

module R : Ohm.Template.HTML with type t = <
    list : Ohm.View.html list ;
    more : Ohm.JsCode.t option
  > ;;

module RW : Ohm.Template.HTML with type t = <
    list      : Ohm.View.html list ;
    id        : Ohm.Id.t ;
    post_url  : string ;
    post_init : FWall.Post.Form.t ;
    actions   : Ohm.I18n.html ;
    more      : Ohm.JsCode.t option 
  > ;;

module Poll : sig

  module New : Ohm.Template.HTML with type t = <
      url  : string ;
      init : FPoll.Create.Form.t
  > ;;

end

module More : Ohm.Template.HTML with type t = <
    list : Ohm.View.html list ;
    more : Ohm.JsCode.t option 
  > ;;

module ShowItem : Ohm.Template.HTML with type t = <
    contents : Ohm.View.html ;
    back     : string
  > ;; 

module Missing : Ohm.Template.HTML with type t = unit
