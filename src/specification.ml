
module J = Yojson.Basic
module E = Errormsg

open J.Util

type param =
  | Global of string
  | Local of string * string

type atomic_prop = {
  name: string;
  default_val: bool;
  valid_span: string * string;
  expr: string;
  params: param list
}

type spec = {
  ltl : string;
  props: atomic_prop list
}

let emptySpec : spec = {
  ltl = "";
  props = []
}


(* Convert the LTL operators of a formula to be compatible with ltl2ba *)
let convert_ltl_operators (f: string) : string =
  f |> (Str.global_replace (Str.regexp_string "G") "[]")
  |> (Str.global_replace (Str.regexp_string "F") "<>")


let get_prop_start (p: atomic_prop) : string =
  fst p.valid_span


let get_prop_end (p: atomic_prop) : string =
  snd p.valid_span


let atomic_prop_to_string (p: atomic_prop) : string =
  Printf.sprintf "Prop %s [%B, %s, %s -> %s]" p.name p.default_val
    p.expr (fst p.valid_span) (snd p.valid_span)


let json_to_param (json: J.json) : param =
  let fullname = to_string json in
  match Str.split (Str.regexp "::") fullname with
  | gname::[] -> Global gname
  | fname::vname::[] -> Local (fname, vname)
  | _ -> assert(false)


let json_to_pa (json: J.json) : atomic_prop =
  let span = match List.map to_string (json |> member "span" |> to_list) with
  | ls::le::[] -> (ls, le)
  | _ -> assert false
  in
  {
    name = json |> member "name" |> to_string;
    default_val = json |> member "default" |> to_bool;
    valid_span = span;
    expr = json |> member "expr" |> to_string;
    params = List.map (json_to_param) (json |> member "params" |> to_list)
  }

let from_json (json: J.json) : spec =
  {
    ltl = json |> member "ltl" |> to_string |> convert_ltl_operators;
    props = List.map json_to_pa (json |> member "pa" |> to_list)
  }

let from_file (filename: string) : spec =
  let json = try J.from_file filename
    with _ -> E.s (E.error "Couldn't parse the file %s" filename )
  in from_json json
