(* in-built modules *)
open Unix
open Printf
open Str

(* user modules *)
include Merkle_interface
include Merkle
include File
include Socket

(* displays the menu *)
let print_menu () = 
	printf "
			(1) Upload a file
			(2) List files
			(3) Download a file
			(4) Remove a file
		"
	;;

let upload_file sock client_index client_file_list= 
	printf "Enter the name of the file you want to upload\n%!";

	let fname = read_line () in 
	let content = File.read_file fname in
	let message = "UPLOAD"^";"^fname^";"^content in

	send sock message 0 (String.length message) [];
    let new_client_file_list = client_file_list @ [fname] in
	Merkle.hash_extract (Merkle_interface.agent_build_merkle new_client_file_list client_index)
;;	

let list_files sock = 	
	let message = "LIST" in
	send sock message 0 (String.length message) [];

	(* wait for the server to send back the list *)
	(* let recv_list = [sock] in 
	Unix.select recv_list, [], [], 5.0; *)

	let list_str = Socket.readall sock in
	printf "Received list: %s\n%!" list_str;
	(* let file_list = split (regexp ";") list_str in *)
	()
;;

let download_file sock client_root_hash  client_index= 
	printf "Enter the name of the file you want to download\n%!";

	let fname = read_line () in 
	let message = "DOWNLOAD"^";"^fname in

	send sock message 0 (String.length message) [];
	printf "Sent request\n%!";

	let content = Socket.readall sock in
	printf "%s\n" content;
	let parsed_content = Str.split (regexp ";") content in
	
	let fileContent = List.hd parsed_content in 
	let hashlist = List.tl parsed_content in
	File.write_file fname fileContent;

	printf "Got file: %s\n%!" fileContent;

	printf "Verifying download..";

	let file_index = Merkle_interface.find_index fname client_index in
	printf "%s\n" content;
	match (Merkle_interface.client_verify client_root_hash hashlist fname file_index ) with
		"true"-> printf "Download successful!\n";
		|"false" -> printf "File has been corrupted.\n";
		|k -> printf "%s\n" k;
	()
;;

let remove_file sock client_index client_file_list= 
	printf "Enter the name of the file you want to delete\n%!";

	let fname = read_line () in 
	let message = "REMOVE"^";"^fname in

	send sock message 0 (String.length message) [];

    let new_client_file_list = (List.filter (fun x -> (String.compare x fname ) != 0) client_file_list )in
	Merkle.hash_extract (Merkle_interface.agent_build_merkle new_client_file_list client_index)
;;

let run_client () = 
  (*get list of files uploaded by client and build merkle tree*)
  let client_index = "client_index_file.txt" in
  let client_file_list = Merkle_interface.get_file_list "client_index_file.txt" in
  let client_root_hash = ref (Merkle.hash_extract (
      match client_file_list with 
      [] -> Merkle.Leaf("","") 
      | _ ->Merkle_interface.agent_build_merkle client_file_list client_index)) in

	while true do
		let client_sock = socket PF_INET SOCK_STREAM 0 in
		connect client_sock (ADDR_INET(inet_addr_of_string "127.0.0.1", 12345));
		printf "Connected to server\n%!";

		print_menu ();	

		let input = read_line () in
		match (int_of_string input) with  
			  1 -> client_root_hash := (upload_file client_sock client_index client_file_list)
			| 2 -> list_files client_sock
			| 3 -> download_file client_sock !client_root_hash  client_index
			| 4 -> client_root_hash := (remove_file client_sock client_index client_file_list)
			| _ -> printf "Try again%!";
				exit 0;
		printf "Closing connection\n%!";
		close client_sock;	
	done;
;;

let () = run_client()
;;