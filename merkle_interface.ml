module Merkle_interface = struct
		

	(* in-built modules *)
	open Unix
	open Printf
	open Str
	open Digest

	(* user modules *)
	include Merkle
	include File

	(* hashes string using md5 *)
	let md5_hasher input_string = Digest.to_hex(Digest.string(input_string))
	;;

	(* abstracted build merkle *)
	let agent_build_merkle filelist index_file= 
		File.write_file index_file "";
		let sorted_filelist = (List.sort compare filelist) in 
		Merkle.build_merkle sorted_filelist md5_hasher "" "" index_file
	;;

	(* find index of file from the index file *)
	let find_index filename index_file =
		let find_ind filename index_file index =(
			let channel = open_in index_file in
			try
				while true do
				    let line = input_line channel in
				    let pair = Str.split (regexp ";") line in
				    if !index = "" then (index := (if filename = (List.hd pair) then (List.nth pair 1) else ""))
				 done
			 with End_of_file ->
			  close_in channel)
		in 
		let temp = ref "" in 
		find_ind filename index_file temp;
		List.hd (split (regexp "\"") !temp)
	;;


	(* client side verification *)
	let client_verify root_hash_val hashlist filename index=
		let file_hash = (Merkle.file_hasher filename md5_hasher) in
		(* recursive function that finds verification hash *)
		let rec compute_hash hashlist index_string file_hash = 
			(
			match hashlist with
			[k] -> (match index.[0] with 
				'0' -> (md5_hasher (file_hash^k)) 
				|'1' ->  (md5_hasher (file_hash^k))) 
			|a::b -> let new_index = String.sub index_string 1 ((String.length index_string)-1) in 
				(match index.[0] with 
				'0' -> (md5_hasher ((compute_hash b new_index file_hash)^a)) 
				|'1' ->  (md5_hasher (a^(compute_hash b new_index file_hash))))
			)
		in
		match index with
		""->"Verification not possible"
		|k -> if root_hash_val = (compute_hash hashlist k file_hash) then "true" else "false"
	;;

	(* generate hashlist on server side *)
	let rec server_gen filename index server_tree hashlist=
		match (String.length index) with
			0 -> hashlist 
			|_ -> let k = index in
				let new_index = String.sub k 1 ((String.length k)-1) in 
				match k.[0] with 
				'0' -> ( match server_tree with
						Merkle.Tree(a,b,c,d) -> let new_hashlist = hashlist @ (Merkle.hash_extract d) in 
												server_gen filename new_index a new_hashlist)
				|'1' ->  ( match server_tree with
						Merkle.Tree(a,b,c,d) -> let new_hashlist = hashlist @ (Merkle.hash_extract a) in 
												server_gen filename new_index d new_hashlist)
				
	;;



end