(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let () = UrlAdmin.def_sqlize $ admin_only begin fun cuid req res -> 

  let! count_users = ohm MUser.Backdoor.count_undeleted in
  let! count_instances = ohm MInstance.Backdoor.count in
  let! count_avatars = ohm MAvatar.Backdoor.count in

  let choices = Asset_Admin_Sqlize.render (object
    method count = count_users + count_instances + count_avatars  
    method url   = Action.url UrlAdmin.getSQL None (0,None)
  end) in

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.sqlize # title 
    method body  = choices
  end) res

end
    
let () = UrlAdmin.def_getSQL $ admin_only begin fun cuid req res ->

  let step, id_opt = req # args in

  let respond ?(count=0) next sql = 
    let args = (if next = None then step + 1 else step), next in
    return (Action.json [
      "count", Json.Int count ;
      "cache", Json.Bool (next <> None) ;
      "sql",   Json.String sql ;
      "url",   Json.String (Action.url (req # self) (req # server) args)
    ] res) 
  in

  let sql_str = Printf.sprintf "%S" in
  let sql_optstr = function None -> "NULL" | Some s -> sql_str s in
  let domain = function
    | None -> "runorg.com"
    | Some wid -> try (ConfigWhite.domain wid) with _ -> "[INCONNU]"
  in

  match step with 

    (* Initial insert *)

    | 0 -> respond None "DROP TABLE IF EXISTS user ;
CREATE TABLE user (
  usr_id CHAR(11) NOT NULL PRIMARY KEY,
  usr_firstname VARCHAR(255), 
  usr_lastname VARCHAR(255), 
  usr_email VARCHAR(255) NOT NULL,
  usr_white VARCHAR(255) NOT NULL
) ;

DROP TABLE IF EXISTS instance ;
CREATE TABLE instance (
  ins_id CHAR(11) NOT NULL PRIMARY KEY,
  ins_name VARCHAR(255) NOT NULL,
  ins_key VARCHAR(255) NOT NULL, 
  ins_white VARCHAR(255)
) ;

DROP TABLE IF EXISTS ins_usr ;
CREATE TABLE ins_usr (
  ins_id CHAR(11) NOT NULL,
  usr_id CHAR(11) NOT NULL,
  ins_usr_status ENUM('visitor','member','admin') NOT NULL,
  PRIMARY KEY (ins_id,usr_id)
) ;
"

    (* Inserting users ===================================================================== *)

    | 1 -> respond None "INSERT INTO user (
  usr_id, usr_firstname, usr_lastname, usr_email, usr_white
) VALUES\n"

    | 2 -> let  uid_opt = BatOption.map IUser.of_id id_opt in 
	   let! users, uid_opt = ohm $ MUser.Backdoor.list ~count:10 uid_opt in
 	   let  count = List.length users in 
	   let  id_opt = BatOption.map IUser.to_id uid_opt in  
	   respond ~count id_opt (String.concat ",\n" (List.map begin fun (uid,user) ->
	     Printf.sprintf "(%s,%s,%s,%s,%s)" 
	       (sql_str (IUser.to_string uid))
	       (sql_optstr (user # firstname))
	       (sql_optstr (user # lastname)) 
	       (sql_str (user # email)) 
	       (sql_str (domain (user # white)))
	   end users))
	   
    | 3 -> respond None ";\n"

    (* Inserting instances ================================================================= *)

    | 4 -> respond None "INSERT INTO instance (
  ins_id, ins_name, ins_key, ins_white
) VALUES\n"

    | 5 -> respond None ""

    | 6 -> respond None ";\n"

    (* Inserting instances ================================================================= *)

    | 7 -> respond None "INSERT INTO ins_usr (
  ins_id, usr_id, ins_usr_status
) VALUES\n"

    | 8 -> respond None "" 

    | 9 -> respond None ";\n"

    (* Finish everything =================================================================== *)

    | _ -> return (Action.json [
      "count", Json.Int 0 ;
      "cache", Json.Bool false ;
      "sql",   Json.String "" ;
      "url",   Json.Null
    ] res) 

end
