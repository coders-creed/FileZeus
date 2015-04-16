open Unix
open Printf

let run_server () = 
  let sock = socket PF_INET SOCK_STREAM 0 in
  bind sock (ADDR_INET(inet_addr_of_string "127.0.0.1", 12345));
  listen sock 5;
  printf "Waiting for connection ...\n%!";

  let (s, _) = accept sock in 
  printf "Accepted a connection\n";

  let cout =  out_channel_of_descr s in
  fprintf cout "Abc%!";

  printf "Closing connection\n";

  close sock;
;;

let () = run_server()
;;
