(* © 2012 Runorg *)

open Ohm

type json t = [
  `List                "list"
| `Group               "grup"
| `Instance            "inst" 
| `Page                "page"
| `I18n                "i18n"
| `Template            "tmpl"
| `Vertical            "vert"
| `EntityTemplate      "etmp"
| `User                "user"
| `Task                "task"
| `Join                "join"
| `Profile             "pfle"
| `Avatar              "avtr"
| `Notification        "ntfy"
| `Layout              "layt"
| `Preregister         "preg"
| `File                "file"
| `Entity              "enty"
| `Feed                "feed"
| `Item                "item"
| `Comment             "comm"
| `Like                "like"
| `LastVisit           "lavi"
| `Poll                "poll"
| `PollAnswer          "pans"
| `Token               "tokn"
| `Message             "mesg"
| `MessageSubscription "msbs"
| `GroupMessage        "gmsg"
| `News                "news"
| `TemplateVersion     "tmpv"
| `VerticalVersion     "vrtv"
| `PreConfigNamer      "pcnm"
];;

let of_json = t_of_json
let to_json = json_of_t
