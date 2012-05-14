(* © 2012 MRunOrg *)

type main = < 
  label : Ohm.I18n.text ;
  seats : int ; 
  memory : int ; 
  daily : (int * int) ;
  days : int 
> ;;

type memory = < label : Ohm.I18n.text ; memory : int ; daily : (int*int) > ;;

let _main name ~label ~seats ~price = 
  IRunOrg.Offer.Assert.main (IRunOrg.Offer.of_string name),
  (object
    method label  = `label label
    method seats  = seats
    method memory = seats * 1024 / 100
    method daily  = (price,365)
    method days   = 365
   end)

let _ag name ~label ~seats ~memory ~price = 
  IRunOrg.Offer.Assert.main (IRunOrg.Offer.of_string name),
  (object
    method label  = `label label
    method seats  = seats
    method memory = memory 
    method daily  = (price,30)
    method days   = 30
   end)    

let main = [
  _main "org50"   ~label:"offer.50"    ~seats:  50 ~price:  72_00 ;
  _main "org100"  ~label:"offer.100"   ~seats: 100 ~price: 120_00 ;
  _main "org150"  ~label:"offer.150"   ~seats: 150 ~price: 180_00 ;
  _main "org250"  ~label:"offer.250"   ~seats: 250 ~price: 300_00 ;
  _main "org350"  ~label:"offer.350"   ~seats: 350 ~price: 420_00 ;
  _main "org500"  ~label:"offer.500"   ~seats: 500 ~price: 540_00 ;
  _main "org750"  ~label:"offer.750"   ~seats: 750 ~price: 810_00 ;
  _main "org1000" ~label:"offer.1000"  ~seats:1000 ~price:1080_00 ;
  _main "org1500" ~label:"offer.1500"  ~seats:1500 ~price:1620_00 ;
  _main "org2000" ~label:"offer.2000"  ~seats:2000 ~price:2160_00 ;
  _main "org2500" ~label:"offer.2500"  ~seats:2500 ~price:2700_00 ;
  _main "org3500" ~label:"offer.3500"  ~seats:3500 ~price:3780_00 ;
  _main "org5000" ~label:"offer.5000"  ~seats:5000 ~price:5400_00 ;
  _ag   "ag200"   ~label:"offer.ag200" ~seats: 200 ~price:  20_00 ~memory: 512
]

let _memory name ~label ~memory ~price = 
  IRunOrg.Offer.Assert.memory (IRunOrg.Offer.of_string name),
  (object
    method label  = `label label
    method memory = memory * 1024
    method daily  = (price,365)
   end)

let memory = [
  _memory "org1g"  ~label:"offer.1g"  ~memory: 1 ~price: 24_00 ;
  _memory "org2g"  ~label:"offer.2g"  ~memory: 2 ~price: 48_00 ;
  _memory "org5g"  ~label:"offer.5g"  ~memory: 5 ~price:120_00 ;
  _memory "org10g" ~label:"offer.10g" ~memory:10 ~price:240_00 ;
]

let print_memory m = 
  if m mod 1024 = 0 then string_of_int (m / 1024) 
  else Printf.sprintf "%.2f" (float_of_int m /. 1024.) 

let print_year_price (n,d) =
  let cents = n * 365 / d in
  let price = float_of_int cents /. 100. in
  Printf.sprintf "%.02f" price

let check list x = 
  try Some (List.find (fun (id,_) -> x = IRunOrg.Offer.decay id) list)
  with Not_found -> None

let check_opt list = function 
  | None -> Some None
  | Some x -> 
    try Some (
      BatList.find_map (fun (id,data) ->
	if x = IRunOrg.Offer.decay id then Some (Some (id,data)) else None
      ) list 
    ) with Not_found -> None
