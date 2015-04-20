open Unix
open Str

module Socket = struct
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
end
