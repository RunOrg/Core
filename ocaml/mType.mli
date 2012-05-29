type t = [
| `List
| `Group
| `Instance 
| `Page
| `I18n
| `Template
| `Vertical
| `EntityTemplate
| `User
| `Task
| `Join
| `Profile
| `Layout
| `Preregister
| `File
| `Avatar
| `Notification
| `Feed
| `Item
| `Entity
| `Comment
| `Like
| `LastVisit
| `Poll 
| `PollAnswer
| `Token
| `Message
| `MessageSubscription
| `GroupMessage
| `News
| `Album
| `TemplateVersion
| `VerticalVersion
| `PreConfigNamer
]

val of_json : Ohm.Json.t -> t
val to_json : t -> Ohm.Json.t

