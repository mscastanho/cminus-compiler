all: tables tree queue bison flex gcc
	@echo "Done."

tables: tables.c
	gcc -Wall -c tables.c

tree: tree.c
	gcc -Wall -c tree.c

queue: queue.c
	gcc -Wall -c queue.c

bison: parser.y
	bison parser.y

flex: scanner.l
	flex scanner.l

gcc: scanner.c parser.c
	gcc -Wall -o trab3 scanner.c parser.c tables.o tree.o queue.o -ly

clean:
	@rm -f *.o *.output *~ scanner.c parser.h parser.c trab3
