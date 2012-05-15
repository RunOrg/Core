(* © 2012 RunOrg *)

val build : 
    uid:'a IUser.id option 
 -> iid:'b IInstance.id option
 -> < home : string ;
      account : < url : string ; name : string > option ;
      menu : <
        logout  : string ;
        network : string ;
	news    : string ;
	account : string 
      > option ;
      asso : <
        picture : < url : string ; pic : string > option ;
        url : string ;
	name : string ;
	menu : <
          home : string ;
	  members : string ;
	  activities : string ;
	  discussions : string
        > option ;
	website : string
      > option
    > O.run 
