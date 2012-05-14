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

val of_json : Json_type.t -> t
val to_json : t -> Json_type.t

