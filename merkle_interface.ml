(* in-built modules *)
open Unix
open Printf
open Str
open Digest

(* user modules *)
include File
include Merkle
include Digest

let md_hasher input_string = Digest.to_hex(Digest.string(input_string));;
