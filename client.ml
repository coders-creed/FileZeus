open Unix
open Printf

let print_menu () = 
	printf "
			(1) Upload a file
			(2) List files
			(3) Get a file
			(4) Remove a file
		"
	;;

let read_file fname =
  let channel = open_in fname in
  let len = in_channel_length channel in
  let str = String.create len in
  really_input channel str 0 len;
  close_in channel;
  
  (str)
;;

let upload_file sock = 
	printf "Enter the name of the file you want to upload\n";

	let fname = read_line () in 
	let content = read_file fname in

	send sock content 0 (String.length content) []
;;	

let list_files sock = 1
;;

let get_file sock = 1
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
			| 3 -> get_file
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