(* © 2012 RunOrg *)

open Ohm
open UrlCoreHelper

let index = new dflt "admin"
let stats = new dflt "admin/stats"
let full_stats = new dflt "admin/full-stats"

let preconfig = new dflt "admin/pre-config"

let preconfig_compact = new dflt "admin/pre-config/compact"

let news  = new dflt "admin/news"
let news_stats = new dflt "admin/stats/news"

let rss = new dflt "admin/test-rss"

let network = new dflt "admin/network"
let network_bind = object (self)
  inherit rest "admin/network/bind"
  method build (iid:IRelatedInstance.t) = 
    self # rest [ IRelatedInstance.to_string iid ]
end

let network_edit = object (self)
  inherit rest "admin/network/edit"
  method build (iid:IInstance.t) = 
    self # rest [ IInstance.to_string iid ]
end

let extract_cookie = new dflt "admin/extract/cookie"

let network_edit_post = object (self)
  inherit rest "admin/network/edit-post"
  method build (iid:IInstance.t) = 
    self # rest [ IInstance.to_string iid ]
end

let clients = new dflt "admin/clients"

let client_gift = object (self)
  inherit rest "admin/clients/gift"
  method build (id : IRunOrg.Client.t) = 
    self # rest [ IRunOrg.Client.to_string id ]
end

let obliterate = new dflt "admin/obliterate"

module Csv = struct
  let users = new dflt "admin/csv/users"
end

let new_template_version_post = new dflt "admin/pre-config/template-version/new-post"

let new_template_version = object (self)
  inherit rest "admin/pre-config/template-version/new"
  method build = self # rest []
  method build_from (id : ITemplate.t) = 
    self # rest [ ITemplate.to_string id ]
end

let edit_template = object (self)
  inherit rest "admin/pre-config/template"
  method build (id : ITemplate.t) = 
    self # rest [ ITemplate.to_string id ]
  method build_create = self # rest []
end

let edit_template_post = object (self) 
  inherit rest "admin/pre-config/template/post"
  method build (id : ITemplate.t) =
    self # rest [ ITemplate.to_string id ]
end

let edit_vertical = object (self)
  inherit rest "admin/pre-config/vertical"
  method build (id : IVertical.t) = 
    self # rest [ IVertical.to_string id ]
  method build_create = self # rest []
end

let edit_vertical_post = object (self) 
  inherit rest "admin/pre-config/vertical/post"
  method build (id : IVertical.t) =
    self # rest [ IVertical.to_string id ]
end

let new_vertical_version_post = new dflt "admin/pre-config/vertical-version/new-post"

let new_vertical_version = object (self)
  inherit rest "admin/pre-config/vertical-version/new"
  method build = self # rest []
  method build_from (id : IVertical.t) = 
    self # rest [ IVertical.to_string id ]
end
    
let edit_i18n = new dflt "admin/i18n"
let edit_i18n_post = new dflt "admin/i18n-post"

let make_admin = new dflt "admin/make-admin"
let make_admin_post = new dflt "admin/make-admin-post"
