(* in-built modules *)
open Unix
open Printf
open Str

(* user modules *)
include File
include Socket

(* directory in which user files are stored *)
let serverdir = "server_files/"

(* get the full name of a file on the server
by appending the directory name to the filename *)
let full_name filename = serverdir^filename
;;


(* handle a client file upload *)
(* fname: name of the file  *)
(* fileContent: an ASCII string with the contents 
of the file *)
let upload_file fname content =
  printf "Uploading file\n%!";

  File.write_file (full_name fname) content; 
;;

(* handles a client file download *)
(* fname: name of the file requested *)
(* sock: socket to which file is sent *)
let download_file fname sock = 
  printf "Downloading: %s\n%!" fname;

  let content = File.read_file (full_name fname) in
  send sock content 0 (String.length content) [];
  printf "%s\n%!" content;
  ()
;;

(* handles a client request to list files *)
(* sock: socket to which file list is sent *)
let list_files sock = 
  printf "Listing files\n%!";

  let file_list = Sys.readdir serverdir in
  let message = String.concat ";" (Array.to_list file_list) in
  printf "%s\n%!" message;

  send sock message 0 (String.length message) [];
  
  ()
;;

(* handles a client request to remove a file
fname: name of file to be removed *)
let remove_file fname = 
  printf "Removing file\n%!";
  Sys.remove (full_name fname)
;;

(* main server function *)
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
    printf "Accepted a connection\n%!";

(* get all data from the client *)
    let str = Socket.readall s in 
    printf "Received: %s\n%!" str;

    let args = split (regexp ";") str in
    let command = List.nth args 0 in

    printf "Command: %s\n%!" command;

(* go to the action function based on command *)
    match command with
    | "UPLOAD" ->
      upload_file (List.nth args 1) (List.nth args 2)
    | "DOWNLOAD" -> 
      download_file (List.nth args 1) s    
    | "LIST" ->
      list_files s
    | "REMOVE" ->
      remove_file (List.nth args 1)
    | _ -> ()
    ;

    printf "Closing connection\n%!";
    shutdown sock SHUTDOWN_ALL;
    close sock;  
  done;

  printf "Closing server\n%!";
;;

let () = run_server()
;;
