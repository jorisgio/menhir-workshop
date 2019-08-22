%token EOF
%token LBRACKET RBRACKET COLON COMMA
%token MINUS PLUS LSQUARE RSQUARE
%token<string> STRING
%token<bool> BOOL
%token<int> INT
%on_error_reduce EOF

%{
  (* exception ParseError of token * Lexing.position * Lexing.position *)

  let make_loc pos = pos

  let make pos json =
    let location = make_loc pos in
    { Ast.loc = location; json }

    open Ast
%}

%start <Ast.ast>json

%%

let field ==
  | ~ = STRING; COLON; ~ = json_value; <>

let assoc ==
  | LBRACKET; fields = separated_list(COMMA, field); RBRACKET; { make $loc (Assoc fields) }

let array ==
  | LSQUARE; elems = separated_list(COMMA, json); RSQUARE; { make $loc (List elems) }

let number ==
  | PLUS?; ~ = INT; <>
  | MINUS; i = INT;  { - i }

let json_value :=
  | s = STRING; { make $loc (String s) }
  | i = number; { make $loc (Int i) }
  | b = BOOL; { make $loc (Bool b) }
  | ~ = assoc; <>
  | ~ = array; <>

let json :=
  ~ = assoc; EOF; <>
