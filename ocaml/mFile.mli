(* © 2013 RunOrg *)

(** A file handle, represents a file that exists in storage. Designed to stick in 
    a third-party object and (at least on Amazon) query the download link without 
    a database access. *)
module Handle : Ohm.Fmt.FMT

(** A path to a temporary file stored on the local server. *)
type local_path = string

(** Information about a file, provided after a successful upload. *)
type upload_info = <
  handle   : Handle.t ;
  filename : string ; 
  size     : float ;  
  local    : local_path
>

(** An action to be performed after an upload finished. *)
module type POSTUPLOADER = sig
  include Ohm.Fmt.FMT
  val id : IFile.PostUploader.t
  val author : t -> (#O.ctx,[`Avatar of IAvatar.t | `User of IUser.t] option) Ohm.Run.t
  val process : t -> upload_info -> (#O.ctx,unit) Ohm.Run.t
end

(** A storage engine, possibly including a parameter to specify API keys and
    the like. *)
module type STORAGE = sig

  (** A handle to an uploaded file, which *SHOULD* exist on the server. *)
  module Handle   : Ohm.Fmt.FMT

  (** A handle to a file that will be uploaded, but has not been uploaded yet. 
      Use {!find} to turn an upload handle into an actual handle. *)
  module UpHandle : Ohm.Fmt.FMT

  include Ohm.Fmt.FMT   

  val id : IFile.Storage.t

  (** The owner of a given store. All files uploaded to this store will count 
      against the quota of that owner. *)
  val owner : t -> [ `User of IUser.t | `Instance of IInstance.t ]

  (** Returns the configuration for creating a client-side form to upload
      the file, and a handle that can be used to retrieve the uploaded file
      after the fact. The client should provide the confirmation URL 
      here. *)
  val prepare : 
       maxsize:float
    -> t 
    -> (#O.ctx, < 
         handle : UpHandle.t ; 
         form   : string -> <
           post   : (string * string) list ; 
	   key    : string ; 
           url    : string ;
         >
       > option) Ohm.Run.t

  (** Find an uploaded file from its upload handle (usually after the 
      upload has been confirmed). *)
  val find : UpHandle.t -> t -> (#O.ctx,Handle.t option) Ohm.Run.t

  (** Generate the download URL for a given handle. Should remain 
      available for a few minutes. *)
  val url : Handle.t -> t -> (#O.ctx,string option) Ohm.Run.t

  (** Upload a file. Data is provided as a path to a file on the server. *)
  val upload : 
       public:bool 
    -> filename:string 
    -> local_path 
    -> t
    -> (#O.ctx, Handle.t option) Ohm.Run.t

  (** Download a file, retrieves both the file name and the data itself
      (represented as a path to a temporary file on the server). Size is 
      expressed in megabytes. *)
  val download : Handle.t -> t -> (#O.ctx,< 
    filename : string ; 
    local    : local_path ;
    size     : float  ;
  > option) Ohm.Run.t

  (** Delete a file, permanently. *)
  val delete : Handle.t -> t -> (#O.ctx,unit) Ohm.Run.t

end

(** A storage system. *)
type store

(** Register a storage system category, can be used to instantiate individual
    storage systems (for instance, by providing API keys). *)
module RegisterStorage : functor(S:STORAGE) -> sig
  type t = S.t
  val make : t -> store
end

(** An upload token, designed to be passed as part of an URL. Keeps track of
    a "to be uploaded" file so that its upload can be confirmed after the client
    has sent the file. *)
module UploadToken : sig
  type t 
  val arg : t Ohm.Action.Args.cell     
end

(** Upload form configuration : when provided with the URL for confirmation, 
    returns the postfields, the key of the field input, and the action URL. *)
type form = string -> < post : (string * string) list ; key : string ; url : string >

(** Define a new upload process with a post-upload processing module. *)
module Uploader : functor(P:POSTUPLOADER) -> sig

  type t = P.t

  (** Prepare an upload. Returns both the upload token to be used when uploading, 
      and the form configuration for the client. *)
  val prepare : 
       ?maxsize:float
    -> store
    -> t 
    -> (#O.ctx, (UploadToken.t * form) option) Ohm.Run.t 

end

(** Confirm that a file has been sent. This triggers the post-uploader. *)
val confirm : UploadToken.t -> (#O.ctx,unit) Ohm.Run.t

(** The store associated with a handle. *)
val store  : Handle.t -> store

(** Delete a file, permanently. *)
val delete : Handle.t -> (#O.ctx,unit) Ohm.Run.t

(** The original uploader of a file. *)
val uploader : Handle.t -> (#O.ctx,[`Avatar of IAvatar.t | `User of IUser.t] option) Ohm.Run.t

(** Upload a temporary local file to the selected storage. *)
val upload : 
      store
  -> [`Avatar of IAvatar.t | `User of IUser.t ] 
  -> ?public:bool 
  -> filename:string 
  -> local_path 
  -> (#O.ctx,Handle.t option) Ohm.Run.t

(** A client-safe download URL for a file. *)
val url : Handle.t -> (#O.ctx,string option) Ohm.Run.t

(** Create a temporary local file from the remote file. *)
val download : Handle.t -> (#O.ctx,<
  filename : string ;
  local : string ;
  size : float
> option) Ohm.Run.t
