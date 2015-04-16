all: client server

server:	server.ml
	ocamlopt -o server unix.cmxa server.ml

client:	client.ml
	ocamlopt -o client unix.cmxa client.ml	

clean:
	rm *.cmi *.cmx 