LIBS=str.cmxa unix.cmxa

COMMON=file socket
COMMONCMX=socket.cmx file.cmx

all: client server

server:	server.ml file socket
	ocamlopt -o server $(LIBS) $(COMMONCMX) server.ml 

client:	client.ml $(COMMON)
	ocamlopt -o client $(LIBS) $(COMMONCMX) client.ml 

file: 
	ocamlopt -o file $(LIBS) file.ml 	

socket:
	ocamlopt -o socket $(LIBS) socket.ml 		

clean:
	rm *.cmi *.cmx 