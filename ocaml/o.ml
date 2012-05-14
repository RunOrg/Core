let environment = `Dev 

let env = match environment with 
  | `Prod -> "prod"
  | `Dev  -> "dev"

let () = 
  Ohm.Configure.set `Log begin match Ohm.Util.role with 
    | `Put
    | `Reset -> "-"
    | `Bot
    | `Web   -> "/var/log/ozone/" ^ env ^ ".log"
  end

module Server = struct
    
  type server = [ `Core | `Client ]
      
  let name_of_server = function
    | `Core   ->   "runorg.com"
    | `Client -> "*.runorg.com"
      
  let suffix = 
    match environment with 
      | `Dev  -> ".dev.runorg.com"
      | `Prod ->     ".runorg.com"
	
  let server_suffix _ = Some suffix
    
  let core = BatString.lchop suffix
    
  let server_of_name name = 
    if name = core then `Core else `Client
      
end

module Action = Ohm.Action.Customize(Server)
module Box    = Ohm.Box.Customize(Action)
module Layout = Ohm.Layout.Customize(Action) 

type 'a run = (Ohm.CouchDB.ctx,'a) Ohm.Run.t
type 'a box = (Ohm.CouchDB.ctx,'a) Box.t
