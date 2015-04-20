(* in-built modules *)
open Unix
open Printf
open Str

(* user modules *)
include File
include Socket

let serverdir = "server_files/"

(* handle a client file upload *)
(* fname: name of the file  *)
(* fileContent: an ASCII string with the contents 
of the file *)

let full_name filename = serverdir^filename
;;


let upload_file fname content =
  File.write_file (full_name fname) content; 
;;

(* handles a client file download *)
(* fname: name of the file requested *)
(* sock: socket to which file is sent *)

let download_file fname sock = 
  printf "download: %s\n%!" fname;
  let content = File.read_file (full_name fname) in
  send sock content 0 (String.length content) [];
  printf "%s\n" content;
  ()
;;

let list_files sock = ()
  let file_list = Sys.readdir serverdir in
  let message = String.concat ";" (Array.to_list (file_list ".")) in
  
  send sock message 0 (String.length message) [];
  ()
;;

let remove_file fname = 
  Sys.remove (full_name fname)
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
    printf "Accepted a connection\n%!";

(* get all data from the client *)
    let str = Socket.readall s in 
    printf "Received: %s\n%!" str;

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
    | _ -> ()
    ;

    printf "Closing connection\n%!";
    close sock;  
  done;

  
  
;;

let () = run_server()
;;
