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

  let step, id = req # args in

  let respond ?(cache=false) ?(count=0) next sql = 
    let args = (if next = None then step + 1 else step), next in
    return (Action.json [
      "count", Json.Int count ;
      "cache", Json.Bool cache ;
      "sql",   Json.String sql ;
      "url",   Json.String (Action.url (req # self) (req # server) args)
    ] res) 
  in

  match step with 
    | 0 -> respond None "DROP TABLE IF EXISTS user ;
CREATE TABLE user (
  usr_id CHAR(11) NOT NULL PRIMARY KEY,
  usr_firstname VARCHAR(255), 
  usr_lastname VARCHAR(255), 
  usr_email VARCHAR(255) NOT NULL,
  usr_white VARCHAR(255)
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
    | _ -> return (Action.json [
      "count", Json.Int 0 ;
      "cache", Json.Bool false ;
      "sql",   Json.String "" ;
      "url",   Json.Null
    ] res) 

end
