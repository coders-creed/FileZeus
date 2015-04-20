(* in-built modules *)
open Unix
open Printf
open Str

(* user modules *)
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

let upload_file sock = 
	printf "Enter the name of the file you want to upload\n";

	let fname = read_line () in 
	let content = File.read_file fname in
	let message = "UPLOAD"^";"^fname^";"^content in

	send sock message 0 (String.length message) []
;;	

let list_files sock = 1
;;

let download_file sock = 
	printf "Enter the name of the file you want to download\n";

	let fname = read_line () in 
	let message = "DOWNLOAD"^";"^fname in

	send sock message 0 (String.length message) [];

	let fileContent = Socket.readall sock in
	File.write_file fname fileContent;

	(1)
;;

let remove_file sock = 1
;;

let run_client () = 
	while true do
		let client_sock = socket PF_INET SOCK_STREAM 0 in
		connect client_sock (ADDR_INET(inet_addr_of_string "127.0.0.1", 12345));
		printf "Connected to server\n";

		print_menu ();	

		let input = read_line () in
		let action_func = 
			match (int_of_string input) with
			  1 -> upload_file
			| 2 -> list_files
			| 3 -> download_file
			| 4 -> remove_file
			| _ -> 
				printf "Try again";
				exit 0;
			in

		action_func client_sock;

		printf "Closing connection\n";
		close client_sock;	
	done;
;;

let () = run_client()
;;