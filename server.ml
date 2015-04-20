open Unix
open Printf
open Str

let SERVER_FILE_DIR = "server_files/";;



(* handle a client file upload *)
(* fname: name of the file  *)
(* fileContent: an ASCII string with the contents 
of the file *)

let upload_file fname fileContent =
  write_file SERVER_FILE_DIR^fname fileContent;  
;;

(* handles a client file download *)
(* fname: name of the file requested *)
(* sock: socket to which file is sent *)

let download_file fname sock = 1
;;

let list_files sock = 1
;;

let remove_file fname = 1
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
    | "DOWNLOAD" -> 
      download_file (List.nth args 1) sock      
    | "LIST" ->
      list_files sock
    | "REMOVE" ->
      remove_file (List.nth args 1)
    ;

    printf "Closing connection\n";
  done;

  close sock;  
  
;;

let () = run_server()
;;
