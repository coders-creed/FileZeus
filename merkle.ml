(* in-built modules *)
open Unix
open Printf
open Str
open Digest

(* user modules *)
include File


(* Type definition of the mekle tree *)
type 'a merkletree =
	 | Leaf of 'a
	 | Tree of 'a merkletree * 'a * 'a merkletree;;

(* pad pads the filelist with 0 string*)
let rec padder filelist pad = 
	match pad with
	0.0 -> filelist
	| _ -> let filelist_dash = filelist @ ["0"] in
				padder filelist_dash (pad-.1.0)
	;;

(* hasher function that finds hash of files in  a file list *)
(* basis_hash takes string argument and gives hash string *)
let rec hasher filelist basis_hash hashlist= 
	match filelist with
	[] -> hashlist
	| a :: b -> let content = 
				match a with 
				"0" -> basis_hash "0"
				| _ ->File.read_file (a) in
				let new_hashlist = hashlist @ [(basis_hash content) ] in
				(hasher b basis_hash new_hashlist)
	;;


(* hashlist pads and hashes the files in filelist and returns list of hashes*)
let rec hash_files filelist pad_func basis_hash hasher_func =
	let list_length = List.length filelist in
	let padded_length = ceil ((log10 (float(List.length filelist)))/. (log10 2.0)) in
	let padded_list = (pad_func filelist (padded_length-.float(list_length))) in
	hasher_func padded_list basis_hash []
;;

	
(* builds the merkle tree *)

(* let rec build_merkle filelist treelist basis_hash =
	match List.length treelist with
	 | 0 -> 
		let trlist=[];
		for i = 0 to endval do

		done
	 
	 | _ -> expr2	 *)	 