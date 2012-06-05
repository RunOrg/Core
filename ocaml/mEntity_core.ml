(* © 2012 MRunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

(* Entity versioned system configuration -------------------------------------------------- *)

module Data = struct
  module T = struct
    type json t = {
      archive  : bool ;
      draft    : bool ;
      public   : bool ;
      admin    : MAccess.t ;
      view     : MAccess.t ;
      group    : IGroup.t ;
      creator  : IAvatar.t option ;
      kind     : MEntityKind.t ;
      template : ITemplate.t ;
      instance : IInstance.t ;
      config   : MEntityConfig.t ;
      deleted  : IAvatar.t option ;
    }
  end
  include T
  include Fmt.Extend(T)
end

module Init = Data

module Reflected = struct
  module T = struct
    type json t = {
      name     : TextOrAdlib.t option ; 
      summary  : string ;
      date     : string option ;
     ?end_date : string option ;
      picture  : IFile.t option 
    }
  end
  include T
  include Fmt.Extend(T)
end
  
module Diff = Fmt.Make(struct
  module ConfigDiff = MEntityConfig.Diff
  module MAvatar = IAvatar
  type json t = 
    [ `Config  of ConfigDiff.t list
    | `Admin   of MAccess.t
    | `Access  of [ `Private | `Normal | `Public ]
    | `Status  of [ `Draft | `Active | `Delete of MAvatar.t ]
    | `Version of string
    ]
end)  

module EntityCoreConfig = struct

  let name = "entity-core"
  module Id = IEntity
  module DataDB = CouchDB.Convenience.Config(struct let db = O.db "entity" end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "entity-v" end)
  module Data = Data
  module Diff = Diff
  module VersionData = MUpdateInfo
  module ReflectedData = Reflected

  type ctx = O.ctx
  let couchDB ctx = (ctx :> CouchDB.ctx) 

  let apply_status t = function 
    | `Draft      -> Data.({ t with draft = true  ; deleted = None })
    | `Active     -> Data.({ t with draft = false ; deleted = None })
    | `Delete who -> Data.({ t with draft = false ; deleted = Some who })

  let apply_admin t admin = Data.({ t with admin = MAccess.optimize admin })

  let apply_access t = function
    | `Private -> Data.({ t with view = `Nobody ; public = false })
    | `Normal  -> Data.({ t with view = `Token  ; public = false })
    | `Public  -> Data.({ t with view = `Token  ; public = true  })

  let apply = function
    | `Admin  a     -> return (fun id time t -> return (apply_admin t a))
    | `Config diffs -> return (fun id time t -> return Data.({ t with config = 
	MEntityConfig.apply_diff t.template t.config diffs }))
    | `Access set   -> return (fun id time t -> return (apply_access t set))
    | `Status set   -> return (fun id time t -> return (apply_status t set))       
    | `Version v    -> return (fun id time t -> return t)

  let reflect id data = 

    (* Reflecting as bot *)
    let bid = IEntity.Assert.bot id in 

    let tmpl = data.Data.template in

    let empty = Reflected.({
      name = None ;
      date = None ;
      end_date = None ;
      summary = "" ;
      picture = None ;
    }) in

    let! entity_data = ohm_req_or (return empty) $ MEntity_data.get bid in
    let data = MEntity_data.data entity_data in

    let safe_string x = try Some (Fmt.String.of_json x) with _ -> None in
    let safe_file   x = try Some (IFile.of_json x) with _ -> None in 

    let extract name f = f (match name with 
      | None -> Json.Null
      | Some name -> try List.assoc name data with Not_found -> Json.Null)
    in

    let reflect = Reflected.({ 
      name     = MEntity_data.name entity_data ;
      date     = extract (PreConfig_Template.Meaning.date tmpl) safe_string ;
      end_date = extract (PreConfig_Template.Meaning.endDate tmpl) safe_string ;
      summary  = BatOption.default "" (extract (PreConfig_Template.Meaning.summary tmpl) safe_string) ;
      picture  = extract (PreConfig_Template.Meaning.picture tmpl) safe_file ;
    }) in

    return reflect

end

module Store = OhmCouchVersioned.Make(EntityCoreConfig)

let _ = 
  Sig.listen MEntity_data.Signals.update (fun id -> Store.reflect (IEntity.decay id))

module Design = struct
  module Database = Store.DataDB
  let name = "entity"
end

type entity = {
  archive  : bool ;
  draft    : bool ;
  public   : bool ;
  admin    : MAccess.t ;
  view     : MAccess.t ;
  group    : IGroup.t ;
  creator  : IAvatar.t option ;
  kind     : MEntityKind.t ;
  template : ITemplate.t ;
  instance : IInstance.t ;
  config   : MEntityConfig.t ;
  deleted  : IAvatar.t option ;
  name     : TextOrAdlib.t option ;
  summary  : string ;
  date     : string option ;
  end_date : string option ;
  picture  : [`GetPic] IFile.id option        
}

module Format = struct
  type t = entity
  include Fmt.ReadExtend(struct
    type t = entity
    let t_of_json json = 
      let stored = Store.Raw.of_json json in
      let c = stored # current and r = stored # reflected in 
      {	archive  = c.Data.archive ;
	draft    = c.Data.draft ;
	public   = c.Data.public ;
	admin    = c.Data.admin ;
	view     = c.Data.view ;
	group    = c.Data.group ;
	creator  = c.Data.creator ;
	kind     = c.Data.kind ;
	template = c.Data.template ;
	instance = c.Data.instance ;
	config   = c.Data.config ;
	deleted  = c.Data.deleted ;
	name     = r.Reflected.name ;
	summary  = r.Reflected.summary ;
	date     = r.Reflected.date ;
	end_date = r.Reflected.end_date ;
	picture  = BatOption.map IFile.Assert.get_pic r.Reflected.picture
      }	
  end)
end

module Table = CouchDB.ReadTable(Store.DataDB)(IEntity)(Format)

