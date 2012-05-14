(* © 2012 RunOrg *)

open BatPervasives

let field_of_entityField (efname,ef) = ( object
  method name     = efname
  method valid    = ef # valid
  method edit     = ef # edit
end :> CField.field )

let config instance fields = 
  FEntity.Fields.make_config ~fields ~render:(fun field -> CField.render (field_of_entityField field) instance)

let render_fields instance fields i18n ctx = 
  let config = config instance fields in 
  let dyn = new FEntity.Form.dyn config i18n in

  let data = fields |> List.map begin fun (name, field) -> 
    let f = `Dyn name in
    (object
      method label = dyn # label f 
      method input = dyn # input f
      method error = dyn # error f
      method required = List.mem `required (field # valid)
      method help = BatOption.map (fun x -> `label x) (field # explain) 
     end)
  end in

  VField.Fields.render data i18n ctx
