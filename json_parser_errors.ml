
(* This file was auto-generated based on "json_parser.messages". *)

(* Please note that the function [message] can raise [Not_found]. *)

let message =
  fun s ->
    match s with
    | 0 ->
        "Json top level value must be an oject\n"
    | 2 ->
        "Missing field value\n"
    | 34 ->
        "Missing field separartor\n"
    | 35 ->
        "Missing field key or value\n"
    | 3 ->
        "Invalid list\n"
    | 32 ->
        "Expecting number before end of input\n"
    | 6 ->
        "Unexpected arithmetic operation on non number value\n"
    | 23 ->
        "Missing list separator between values\n"
    | 24 ->
        "Trailing separator in list\n"
    | 8 ->
        "Unclosed list in object field\n"
    | 19 ->
        "Unexpected arithmetic operation applied to non number value\n"
    | 10 ->
        "Unexpected arithmetic operation applied to non number value inside list\n"
    | 12 ->
        "Unclosed list inside object\n"
    | 13 ->
        "Unclosed object inside list\n"
    | 28 ->
        "Unexpected list termination in object key position\n"
    | 1 ->
        "Unexpected list in object key\n"
    | 38 ->
        "Unexpected value after end of object\n"
    | _ ->
        raise Not_found
