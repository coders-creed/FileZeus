open Unix
open Str

module Socket = struct
	(* read everything pending in the socket *) 
	(* from http://www.brool.com/index.php/ocaml-sockets *)
	let readall socket = 
		let buffer = String.create 512 in
		let count = recv socket buffer 0 512 [] in
		String.sub buffer 0 count;
end
