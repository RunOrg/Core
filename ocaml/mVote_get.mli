(* © 2012 RunOrg *)

open MVote_common

val id        : 'any vote -> 'any IVote.id
val creator   : [<`Read|`Vote|`Admin] vote -> IAvatar.t 
val created   : [<`Read|`Vote|`Admin] vote -> float
val anonymous : [<`Read|`Vote|`Admin] vote -> bool
 
