LIBS=str.cmxa unix.cmxa
COMMON=file.ml

all: client server

server:	server.ml file
	ocamlopt -o server $(LIBS) server.ml 

client:	client.ml file
	ocamlopt -o client $(LIBS) client.ml 

file: 
	ocamlopt -o file $(LIBS) file.ml 	
clean:
	rm *.cmi *.cmx 