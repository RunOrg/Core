(* © 2012 RunOrg *)

open Ohm

module Core = struct

  open UrlCoreHelper

  let ok_pic ()     = ( object (self)
    inherit rest "pic/confirm"
    method build id = 
      self # rest [id]
  end )
    
  let get_pic       = new dflt "pic/get"
  let put_pic       = new dflt "pic/put"
    
end

module Client = struct

  open UrlClientHelper
    
  let ok_pic ()     = ( object (self)
    inherit rest "pic/confirm"
    method build instance id = 
      self # rest instance [id]
  end )
    
  let get_pic       = new dflt "pic/get"
  let put_pic       = new dflt "pic/put"

  let ok_img ()     = ( object (self)
    inherit rest "img/confirm"
    method build instance id = 
      self # rest instance [id]
  end )   

  let put_img ()     = ( object (self)
    inherit rest "img/put"
    method build instance (album : [`Write] IAlbum.id) = 
      self # rest instance [IAlbum.to_string album]
  end )

  let ok_doc ()     = ( object (self)
    inherit rest "doc/confirm"
    method build instance id = 
      self # rest instance [id]
  end )   

  let put_doc ()    = ( object (self)
    inherit rest "doc/put"
    method build instance (folder : [`Write] IFolder.id) = 
      self # rest instance [IFolder.to_string folder]
  end )
    
end
