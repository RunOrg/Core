(* © 2012 RunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = 
    [ `File "???"
    | `Text "txt"
    | `Image "img"
    | `Powerpoint "ppt"
    | `Excel "xls"
    | `Word "doc"
    | `Web "htm"
    | `Archive "zip"
    | `PDF "pdf"
    ]
end)

let extension_of_file filename = 
  try let _, ext = BatString.rsplit filename "." in
      match String.lowercase ext with 

	| "txt" -> `Text

	| "jpg" | "jpeg" | "bmp"
	| "png" | "tif"  | "tiff"
	| "gif" | "svg"  | "xcf"  | "psd" -> `Image

	| "ppt" | "pptx" | "odp" -> `Powerpoint

	| "xls" | "xlsx" | "ods" | "csv" -> `Excel

	| "doc" | "docx" | "rtf" -> `Word

	| "htm" | "html" -> `Web

	| "zip" | "rar" | "tar" 
	| "gz"  | "tgz" | "ace" -> `Archive

	| "pdf" -> `PDF

	| _ -> `File

  with Not_found -> `File
