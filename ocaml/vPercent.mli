(* © 2012 RunOrg *)

(** Compute a percentage. [compute total subtotal] returns a floating-point number
    representing the percentage of [subtotal] within [total]. For instance,
    [compute 8 2] would return [25.0].

    For optimization, you may evaluate and store [compute total] and apply it to 
    all subtotals. 
*)
val compute : int -> int -> float
