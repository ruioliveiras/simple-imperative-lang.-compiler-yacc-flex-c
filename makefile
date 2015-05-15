ALL: y.tab.o lex.yy.o main.o
	gcc -o play $^ -ll

token: tokenizer.o lex.yy.o
	gcc -o play tokenizer.o lex.yy.o -ll

tokenizer.o: tokenizer.c
	gcc -c tokenizer.c

main.o: main.c
	gcc -c main.c

y.tab.o: y.tab.c lex.yy.c
	gcc -c y.tab.c

y.tab.c: yacc.y
	yacc -d -v yacc.y 

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

lex.yy.c: alex.l
	flex alex.l

clean: 
	rm *.o lex.yy.c y.tab.c y.tab.h y.output play

