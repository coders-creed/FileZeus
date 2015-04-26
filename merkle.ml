
	
(* in-built modules *)
open Unix
open Printf
open Str
open Digest

(* user modules *)
include File


(* Type definition of the mekle tree *)
type ('b, 'a) merkletree =
	 | Leaf of 'b * 'a
	 | Tree of ('b, 'a) merkletree * 'b * 'a * ('b, 'a) merkletree;;

(* pad pads the filelist with 0 string*)
let rec padder filelist pad = 
	match pad with
	0.0 -> filelist
	| _ -> let filelist_dash = filelist @ ["0"] in
				padder filelist_dash (pad-.1.0)
	;;



let file_hasher file basis_hash =
	let content = 
	(match file with 
	"0" -> basis_hash "0"
	| _ ->File.read_file file) 
	in
	basis_hash content;;

(* hasher function that finds hash of files in  a file list *)
(* basis_hash takes string argument and gives hash string *)
let rec hasher filelist basis_hash hashlist= 
	match filelist with
	[] -> hashlist
	| a :: b -> let hashed_val= (file_hasher a basis_hash) in
				let new_hashlist = hashlist @ [ hashed_val ] in
				(hasher b basis_hash new_hashlist)
	;;


(* hashlist pads and hashes the files in filelist and returns list of hashes*)
let hash_files filelist basis_hash =
	let list_length = List.length filelist in
	let padded_length = ceil ((log10 (float(List.length filelist)))/. (log10 2.0)) in
	let padded_list = (padder filelist ((2.0**padded_length)-.float(list_length))) in
	hasher padded_list basis_hash []
;;

let rec list_select input_list start_index end_index = 
	match start_index with
	0 -> (if end_index = 0 then [(List.hd input_list)] else [(List.hd input_list)] @ list_select (List.tl input_list) start_index (end_index -1))
	| k -> list_select (List.tl input_list) (k-1) (end_index-1);; 
	
let hash_extract tree = 
	match tree with
	Leaf(b,a) -> a
	| Tree(q,w,e,r) -> e;;


(* builds the merkle tree *)


let rec build_merkle filelist basis_hash child_id prefix index_file=
	let filelist_length =( List.length filelist) in
	match filelist_length with
	1 -> let r = 
		(match List.hd filelist with "0" -> () 
		| filer -> (* File.append_file index_file (filer^";"^prefix^"\n"); *) ()) in 
			Leaf(child_id, file_hasher (List.hd filelist) basis_hash)
	| k -> let left_half = (list_select filelist 0 ((k/2)-1)) in 
		   let right_half = (list_select filelist (k/2) (k-1)) in
		   let left_half_tree = (build_merkle left_half basis_hash "0" (prefix^"0") index_file) in 
		   let right_half_tree = (build_merkle right_half basis_hash "1" (prefix^"1") index_file) in  
	       Tree(left_half_tree, child_id, (basis_hash ((hash_extract left_half_tree)^(hash_extract right_half_tree))), right_half_tree);;

