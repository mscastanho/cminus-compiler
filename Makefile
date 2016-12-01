all: tables tree list stack interpreter bison flex gcc
	@echo "Done."

tables: tables.c
	gcc -Wall -c tables.c

tree: tree.c
	gcc -Wall -c tree.c

list: list.c
	gcc -Wall -c list.c

stack: stack.c
	gcc -Wall -c stack.c

interpreter: interpreter.c
	gcc -Wall -c interpreter.c

bison: parser.y
	bison parser.y

flex: scanner.l
	flex scanner.l

gcc: scanner.c parser.c
	gcc -Wall -o trab3 scanner.c parser.c interpreter.o tables.o tree.o list.o stack.o -ly

clean:
	@rm -f *.o *.output *~ scanner.c parser.h parser.c trab3
