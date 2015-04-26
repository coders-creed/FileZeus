LIBS=str.cmxa unix.cmxa

# labels of dependencies
COMMON=file socket merkle merkle_interface
MERKLEDEP=file
MERKLEINT= merkle file
# .cmx files of dependencies
COMMONCMX=socket.cmx file.cmx merkle.cmx merkle_interface.cmx
MERKLEDEPCMX=file.cmx
MERKLEINTCMX= file.cmx merkle.cmx

EXECUTABLES=client server socket file merkle merkle_interface

all: client server merkle merkle_interface

server:	server.ml $(COMMON)
	ocamlopt -o server $(LIBS) $(COMMONCMX) server.ml 

client:	client.ml $(COMMON)
	ocamlopt -o client $(LIBS) $(COMMONCMX) client.ml 


merkle:	merkle.ml $(MERKLEDEP)
	ocamlopt -o merkle $(LIBS) $(MERKLEDEPCMX) merkle.ml 

merkle_interface:	merkle_interface.ml $(MERKLEINT)
	ocamlopt -o merkle_interface $(LIBS) $(MERKLEINTCMX) merkle_interface.ml 


file: 
	ocamlopt -o file $(LIBS) file.ml 	

socket:
	ocamlopt -o socket $(LIBS) socket.ml 		

clean:
	rm *.cmi *.cmx $(EXECUTABLES)
