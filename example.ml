module I = Json_parser.MenhirInterpreter
module S = MenhirLib.General

let state checkpoint : int =
  match Lazy.force (I.stack checkpoint) with
  | S.Nil ->
      (* Hmm... The parser is in its initial state. Its number is
         usually 0. This is a BIG HACK. TEMPORARY *)
      0
  | S.Cons (Element (s, _, _, _), _) ->
      I.number s

let handle_syntax_error lexbuf checkpoint =
  let message =
    match Json_parser_errors.message (state checkpoint) with
    | exception Not_found ->
        "Syntax error"
    | msg ->
        msg
  in
  Format.fprintf Format.err_formatter "%s %a\n%!" message Ast.pp_pos
    (fst @@ Sedlexing.lexing_positions lexbuf)

let rec loop next_token lexbuf (checkpoint : Ast.ast I.checkpoint) =
  match checkpoint with
  | I.InputNeeded _env ->
      let token = next_token () in
      let checkpoint = I.offer checkpoint token in
      loop next_token lexbuf checkpoint
  | I.Shifting _ | I.AboutToReduce _ ->
      let checkpoint = I.resume checkpoint in
      loop next_token lexbuf checkpoint
  | I.HandlingError env ->
      handle_syntax_error lexbuf env
  | I.Accepted ast ->
      Format.fprintf Format.std_formatter "%a\n%!" Ast.pp_ast ast
  | I.Rejected ->
      (* Cannot happen as we stop at syntax error immediatly *)
      assert false

let process lexbuf =
  let lexer = Json_lexer.lexer lexbuf in
  try
    loop lexer lexbuf
      (Json_parser.Incremental.json (fst @@ Sedlexing.lexing_positions lexbuf))
  with Json_lexer.LexError (pos, msg) ->
    Format.fprintf Format.err_formatter "lexing error : %s at %a%!" msg
      Ast.pp_pos pos

let _ =
  let lexbuf = Sedlexing.Utf8.from_channel stdin in
  process lexbuf
