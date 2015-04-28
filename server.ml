(* in-built modules *)
open Unix
open Printf
open Str

(* user modules *)
include Merkle_interface
include Merkle
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
let upload_file fname content server_file_list server_index=
  printf "Uploading file\n%!";

  let full_fname = full_name fname in
  File.write_file full_fname content; 
  
  server_file_list := !server_file_list @ [full_fname];
  Merkle_interface.agent_build_merkle !server_file_list server_index
;;

(* handles a client file download *)
(* fname: name of the file requested *)
(* sock: socket to which file is sent *)
let download_file fname sock server_tree server_index= 
  printf "Downloading: %s\n%!" fname;

  let full_fname = full_name fname in
  let content = File.read_file full_fname in
  
  
  printf "%s\n%!" content;

  let index = Merkle_interface.find_index full_fname server_index in
  let hashlist = Merkle_interface.server_gen full_fname index server_tree [] in
  let string_hashlist = String.concat ";" hashlist in
  let concat_string = content^";"^string_hashlist in
  send sock concat_string 0 (String.length concat_string) [];

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
let remove_file fname server_file_list server_index= 
  printf "Removing file\n%!";
  let full_fname = full_name fname in
  Sys.remove (full_name fname);
  server_file_list := (List.filter (fun x -> (String.compare x full_fname) != 0) !server_file_list );
  Merkle_interface.agent_build_merkle !server_file_list server_index

;;

(* main server function *)
let run_server () = 
  (*get list of files uploaded by client and build merkle tree*)
  let server_index = "server_index_file.txt" in
  let server_file_list = ref(Merkle_interface.get_file_list "server_index_file.txt") in
  let server_tree = ref (
      match !server_file_list with 
      [] -> Merkle.Leaf("","") 
      | _ ->Merkle_interface.agent_build_merkle !server_file_list server_index) in

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
      server_tree := upload_file (List.nth args 1) (List.nth args 2) server_file_list server_index
    | "DOWNLOAD" -> 
      download_file (List.nth args 1) s !server_tree server_index  
    | "LIST" ->
      list_files s
    | "REMOVE" ->
      server_tree := remove_file (List.nth args 1) server_file_list server_index
    | _ -> ()
    ;

    printf "Closing connection\n%!";
    shutdown sock SHUTDOWN_ALL;
    close sock;  
  done;

  printf "Closing server\n%!"
;;

let () = run_server()
;;
