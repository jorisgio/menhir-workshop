json_parser.messages: json_parser.mly
	menhir --canonical --list-errors json_parser.mly > json_parser.messages

.PHONY: json_parser_errors.ml

json_parser_errors.ml: json_parser.mly
	menhir --canonical json_parser.mly --compile-errors json_parser.messages > json_parser_errors.ml
