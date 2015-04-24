LIBS=str.cmxa unix.cmxa

# labels of dependencies
COMMON=file socket
MERKLEDEP=file
# .cmx files of dependencies
COMMONCMX=socket.cmx file.cmx
MERKLEDEPCMX=file.cmx

all: client server merkle

server:	server.ml $(COMMON)
	ocamlopt -o server $(LIBS) $(COMMONCMX) server.ml 

client:	client.ml $(COMMON)
	ocamlopt -o client $(LIBS) $(COMMONCMX) client.ml 


merkle:	merkle.ml $(MERKLEDEP)
	ocamlopt -o client $(LIBS) $(MERKLEDEPCMX) merkle.ml 


file: 
	ocamlopt -o file $(LIBS) file.ml 	

socket:
	ocamlopt -o socket $(LIBS) socket.ml 		

clean:
	rm *.cmi *.cmx