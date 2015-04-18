open Unix
open Printf
open Str

(* read everything pending in the socket *) 
(* from http://www.brool.com/index.php/ocaml-sockets *)
let readall socket = 
    let buffer = String.create 512 in
    let rec _readall accum = 
      try 
        let count = (recv socket buffer 0 512 []) in
          if count = 0 then accum else _readall ((String.sub buffer 0 count)::accum)
        with _ -> 
          accum
    in
      String.concat "" (List.rev (_readall []))
  ;;

(* handle a client file upload *)
(* fname: name of the file  *)
(* fileContent: an ASCII string with the contents 
of the file *)
let upload_file fname fileContent =
  (* printf "%s" fileContent; *)
  let newFname = "server_files/"^fname in
  let channel = open_out newFname in
  fprintf channel "%s" fileContent;
  close_out channel;
;;

let run_server () = 
(* create a socket for listening *)
  let sock = socket PF_INET SOCK_STREAM 0 in
  setsockopt sock SO_REUSEADDR true;
  bind sock (ADDR_INET(inet_addr_of_string "127.0.0.1", 12345));
  listen sock 5;

(* wait for a client *)
  while true do
    printf "Waiting for connection ...\n%!";

    let (s, _) = accept sock in 
    printf "Accepted a connection\n";

(* get all data from the client *)
    let str = readall s in 
    let args = split (regexp ";") str in
    let command = List.nth args 0 in

(* go to the action function based on command *)
    match command with
    | "UPLOAD" ->
       upload_file (List.nth args 1) (List.nth args 2)
    | _ -> ()
    ;

    printf "Closing connection\n";
  done;

  close sock;  
  
;;

let () = run_server()
;;
