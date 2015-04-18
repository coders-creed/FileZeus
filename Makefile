LIBS=str.cmxa unix.cmxa

all: client server

server:	server.ml
	ocamlopt -o server $(LIBS) server.ml 

client:	client.ml
	ocamlopt -o client $(LIBS) client.ml 

clean:
	rm *.cmi *.cmx 