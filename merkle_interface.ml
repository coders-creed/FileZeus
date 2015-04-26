(* in-built modules *)
open Unix
open Printf
open Str
open Digest

(* user modules *)
include Merkle
include File


let md_hasher input_string = Digest.to_hex(Digest.string(input_string));;

let client_build_merkle filelist index_file= 
	File.write_file index_file "";
	let hashed_list = (Merkle.hash_files filelist md_hasher) in 
	Merkle.build_merkle;;
