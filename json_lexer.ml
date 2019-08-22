open Sedlexing
open Astring

type token = Json_parser.token

open Json_parser

exception LexError of Lexing.position * string

let digit = [%sedlex.regexp? '0' .. '9']

let number = [%sedlex.regexp? Plus digit]

let blank = [%sedlex.regexp? ' ' | '\t']

let newline = [%sedlex.regexp? '\r' | '\n' | "\r\n"]

let any_blank = [%sedlex.regexp? blank | newline]

let letter = [%sedlex.regexp? 'a' .. 'z' | 'A' .. 'Z']

let decimal_ascii = [%sedlex.regexp? Plus ('0' .. '9')]

let octal_ascii = [%sedlex.regexp? "0o", Plus ('0' .. '7')]

let hex_ascii = [%sedlex.regexp? "0x", Plus (('0' .. '9' | 'a' .. 'f' | 'A' .. 'F'))]

let rec nom buf =
  match%sedlex buf with
  | Plus any_blank -> nom buf
  | _ -> ()

let string buf =
  let buffer = Buffer.create 10 in
  let rec read_string buf =
    match%sedlex buf with
    | {|\"|} ->
      Buffer.add_char buffer '"';
      read_string buf
    | '"' -> STRING (Buffer.contents buffer)
    | Star (Compl '"') ->
      Buffer.add_string buffer (Utf8.lexeme buf);
      read_string buf
    | _ -> assert false
  in
  read_string buf

let digit_value c =
  let open Stdlib in
  match c with
  | 'a' .. 'f' -> 10 + Char.code c - Char.code 'a'
  | 'A' .. 'F' -> 10 + Char.code c - Char.code 'A'
  | '0' .. '9' -> Char.code c - Char.code '0'
  | _ -> assert false

let num_value buffer ~base ~first =
  let buf = Utf8.lexeme buffer in
  let c = ref 0 in
  for i = first to String.length buf do
    let v = digit_value buf.[i] in
   assert (v < base);
    c := (base * !c) + v
  done;
  !c

let token buf =
  nom buf;
  match%sedlex buf with
  | eof -> EOF
  | "" -> EOF
  | '-' -> MINUS
  | '+' -> PLUS
  | '"' -> string buf
  | ':' -> COLON
  | '{' -> LBRACKET
  | '}' -> RBRACKET
  | ',' -> COMMA
  | "true" -> BOOL true
  | "false" -> BOOL false
  | hex_ascii ->
      let number = num_value ~base:16 ~first:2 buf in
      INT number
  | octal_ascii ->
      let number = num_value ~base:8 ~first:2 buf in
      INT number
  | decimal_ascii ->
      let number = num_value ~base:8 ~first:2 buf in
      INT number
  | _ ->
    let position = fst @@ lexing_positions buf in
    let tok = Utf8.lexeme buf in
    raise @@ LexError (position, Printf.sprintf "unexpected character %S" tok)

let lexer buf =
  Sedlexing.with_tokenizer token buf
