
let pp_pos out { Ppxlib.pos_lnum; pos_cnum; pos_bol; _} =
  Format.fprintf out "line %d:%d" pos_lnum (pos_cnum - pos_bol)

type loc = Ppxlib.position * Ppxlib.position

let pp_loc out loc = Format.fprintf out "%a-%a" pp_pos (fst loc) pp_pos (snd loc)

type json =
  | String of string
  | Int of int
  | Bool of bool
  | List of ast list
  | Assoc of (string * ast) list
  [@@deriving show]

and ast = {
  loc : loc;
  json : json
}
[@@deriving show]

