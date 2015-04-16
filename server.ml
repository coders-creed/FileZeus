open Unix
open Printf

(* read everything pending in the socket *) 
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

let run_server () = 

  let sock = socket PF_INET SOCK_STREAM 0 in
  bind sock (ADDR_INET(inet_addr_of_string "127.0.0.1", 12345));
  listen sock 5;

  while true do
    printf "Waiting for connection ...\n%!";

    let (s, _) = accept sock in 
    printf "Accepted a connection\n";

    let str = readall s in 
    printf "%s" str;

    printf "Closing connection\n";
  done;

  close sock;  
  
;;

let () = run_server()
;;
