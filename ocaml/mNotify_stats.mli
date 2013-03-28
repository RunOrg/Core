(* © 2013 RunOrg *)

val from_mail : INotify.t -> unit O.run 
  
val from_site : INotify.t -> unit O.run 

val from_zap : INotify.t -> unit O.run
  
val get : INotifyStats.t -> < created : int ; sent : int ; seen : int > O.run 
