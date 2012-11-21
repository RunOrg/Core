| `Delegate_Help kind -> begin match kind with 
    | `Event -> "Les organisateurs disposent de tous les pouvoirs sur cette activité."
    | `Group -> "Les responsables disposent de tous les pouvoirs sur ce groupe et son forum."
    | `Forum -> "Les modérateurs disposent de tous les pouvoirs sur ce forum."
end

| `Delegate_Help_List kind -> begin match kind with 
    | `Event -> "La liste ci-dessous recense les organisateurs actuels :"
    | `Group -> "La liste ci-dessous recense les responsables actuels :"
    | `Forum -> "La liste ci-dessous recense les modérateurs actuels :"
end

