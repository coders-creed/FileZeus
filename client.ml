open Unix
open Printf

let run_client () = 
	let client_sock = socket PF_INET SOCK_STREAM 0 in
	connect client_sock (ADDR_INET(inet_addr_of_string "127.0.0.1", 12345));

	printf "Connected to server\n";

	let buffer = String.create 512 in
	let count = (recv client_sock buffer 0 512 []) in

	printf "%s\n" buffer;

	close client_sock;
;;

let () = run_client()
;;