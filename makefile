ALL: y.tab.o lex.yy.o main.o
	gcc -o play $^ -ll

main.o: main.c
	gcc -c main.c

y.tab.o: y.tab.c lex.yy.c
	gcc -c y.tab.c

y.tab.c: compiler.y
	yacc -d -v compiler.y 

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

lex.yy.c: parser.l
	flex parser.l

clean: 
	rm *.o y.tab.h y.tab.c y.output lex.yy.c play

