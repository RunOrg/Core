(* © 2012 RunOrg *)

open Ohm

type item = 
  [ `Template of 
    < version : string ; diff : MPreConfig.TemplateDiff.t >
  | `Vertical of 
    < version : string ; vertical : IVertical.t ; diff : MPreConfig.VerticalDiff.t >
  ] 

let version_of = function
  | `Template t -> t # version
  | `Vertical v -> v # version 

let kind_of = function 
  | `Template _ -> `Template
  | `Vertical _ -> `Vertical

let other_kind = function 
  | `Template -> `Vertical
  | `Vertical -> `Template

let different_verticals a b = 
  match a, b with 
    | `Vertical a, `Vertical b -> a # vertical <> b # vertical 
    |  _ , _ -> false

let channels_of = function 
  | `Template t -> begin match t # diff with 
      | `Config c -> begin match c with 
	  | `NoGroup 
	  | `Group_WaitingList _ 
	  | `Group_Payment     _ 
	  | `Group_PublicList  _
	  | `Group_Validation  _ 
	  | `Group_Semantics   _ 
	  | `Group_Read        _
	  | `Group_GrantTokens _ -> [`Group]
	  | `NoWall
	  | `Wall_Read   _
	  | `Wall_Write  _
	  | `Wall_Hidden _ -> [`Wall]
	  | `NoAlbum
	  | `Album_Read   _
	  | `Album_Write  _ 
	  | `Album_Hidden _ -> [`Album] 
	  | `NoFolder
	  | `Folder_Read   _ 
	  | `Folder_Write  _ 
	  | `Folder_Hidden _ -> [`Folder]
	  | `NoVotes
	  | `Votes_Read _ 
	  | `Votes_Vote _ -> [`Votes]
      end
      | `Info   _ -> [`Info] 
      | `Field  _ -> [`Field] 
      | `Column _ -> [`Column] 
      | `Join   _ -> [`Join] 
      | `Propagate _ -> [`Propagate]
  end
  | `Vertical t -> begin match t # diff with 
      | `Propagate _ -> [`Propagate;`Entity] 
      | `Entities  e -> begin match e with 
	  | `Create _ -> [`Entity] 
	  | `Update u -> [`Entity]
	  | `Config c -> `Entity :: List.map begin function  
	      | `NoGroup 
	      | `Group_WaitingList _ 
	      | `Group_Payment     _ 
	      | `Group_PublicList  _
	      | `Group_Validation  _ 
	      | `Group_Semantics   _ 
	      | `Group_Read        _
	      | `Group_GrantTokens _ -> `Group
	      | `NoWall
	      | `Wall_Write  _ 
	      | `Wall_Read   _ 
	      | `Wall_Hidden _ -> `Wall
	      | `NoAlbum
	      | `Album_Read   _ 
	      | `Album_Write  _ 
	      | `Album_Hidden _ -> `Album 
	      | `NoFolder
	      | `Folder_Read   _ 
	      | `Folder_Write  _  
	      | `Folder_Hidden _ -> `Folder
	      | `NoVotes
	      | `Votes_Read _ 
	      | `Votes_Vote _ -> `Votes
	  end (c # diffs) 
      end 
  end

let can_swap (a,ca) (b,cb) = 
  if different_verticals a b then true else
    if version_of b > version_of a then true else
      if List.exists (fun c -> List.mem c cb) ca then false else true

let construct_versions () = 
  
  let all_vertical_versions = 
    List.concat (List.map (fun version -> 
      List.concat (List.map (fun vertical -> 
	List.map (fun diff -> 
	  `Vertical (object
	    method version  = MPreConfig.version version 
	    method vertical = vertical
	    method diff     = diff
	  end)
	) (MPreConfig.payload version)
      ) (MPreConfig.applicable version))
    ) MPreConfig.vertical_versions)
  in

  let all_template_versions = 
    List.concat (List.map (fun version -> 
      List.concat (List.map (fun template -> 
	List.map (fun diff -> 
	  template, `Template (object
	    method version  = MPreConfig.version version 
	    method diff     = diff
	  end)
	) (MPreConfig.payload version)
      ) (MPreConfig.applicable version))
    ) MPreConfig.template_versions)
  in

  let all_verticals = 
     BatList.unique (List.map (function `Vertical v -> v # vertical) all_vertical_versions) 
  in

  let template_of_name = 
    BatList.filter_map begin function `Vertical v -> 
      match v # diff with 
	| `Entities (`Create c) -> Some ((v # vertical, c # name), c # template)
	| _                     -> None
    end all_vertical_versions
    @ List.map (fun v -> ((v,"admin"),ITemplate.of_string "admin")) all_verticals
  in

  let all_vertical_versions_by_template = 
    BatList.filter_map begin function `Vertical v -> 
      let name = match v # diff with 
	| `Entities (`Create c) -> c # name
	| `Entities (`Update u) -> u # name
	| `Entities (`Config c) -> c # name
	| `Propagate g -> g # src
      in
      try let template = List.assoc (v # vertical, name) template_of_name in
	  Some (template, `Vertical v)
      with Not_found -> None
    end all_vertical_versions
  in

  let all_templates = 
    BatList.unique (
      List.map fst all_vertical_versions_by_template
      @ List.map fst all_template_versions
    )
  in

  let process_template (versions,id) template = 

    let diffs = 
      List.map snd (
	List.filter (fun (t,_) -> t = template) all_vertical_versions_by_template
	@ List.filter (fun (t,_) -> t = template) all_template_versions
      )
    in

    let sorted_diffs = 
      List.stable_sort (fun a b -> compare (version_of a) (version_of b)) diffs 
    in

    let diffs_with_channels = 
      List.map (fun d -> d, channels_of d) sorted_diffs
    in

    let rec find kind acc = function
      | [] -> None
      | item :: t -> 
	if 
	  kind_of (fst item) = kind
	  && List.for_all (fun item' -> can_swap item item') acc 
	then Some (List.rev acc @ t, item)
	else find kind (item :: acc) t 
    in
    
    let rec extract kind current built = function 
      | [] -> let built = 
		if current = [] then built else (kind, List.rev current) :: built
	      in 
	      List.rev built
      | (h :: t) as list ->
	match find kind [] list with 
	  | Some (rest, item) -> extract kind ((fst item) :: current) built rest
	  | None -> let built = 
		      if current = [] then built else (kind, List.rev current) :: built
		    in 
		    extract (other_kind kind) [fst h] built t
    in

    let lists = extract `Template [] [] diffs_with_channels in

    let versions, id = List.fold_left (fun (versions,id) (kind,(list : item list)) -> 
      match kind with 
	| `Template -> 
	  (`Template (object
	    method applies = [template] 
	    method version = Id.str id 
	    method payload = BatList.filter_map begin function 
	      | `Template t -> Some (t # diff)
	      | `Vertical v -> None 
	    end list
	  end)) :: versions, Id.next id
	| `Vertical -> 
	  let verticals = BatList.unique (BatList.filter_map (function 
	    | `Template _ -> None
	    | `Vertical v -> Some (v # vertical)) list)
	  in
	  List.fold_left (fun (versions,id) vertical -> 
	    (`Vertical (object
	      method applies = [vertical] 
	      method version = Id.str id
	      method payload = BatList.filter_map begin function 
		| `Template t -> None
		| `Vertical v -> if v # vertical = vertical then 
		    Some (v # diff) else None
	      end list
	    end)) :: versions, Id.next id)
	    (versions,id) verticals
    ) (versions,id) lists in
		
    versions, id
  in

  let versions, _ =
    List.fold_left process_template ([],Id.of_string "00000000000")
      all_templates
  in

  versions 
	
