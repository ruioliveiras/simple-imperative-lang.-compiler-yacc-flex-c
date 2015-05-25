%{
#include <stdio.h>
#include <string.h>
#include "compiler.h"
#include "y.tab.h"
#include "stack.h"


void yyerror(char *s);
extern ccLine;

static int total;
static int actual;
static Stack s;
// falta a variavel
// duvida na lista/conjunto de instruções
// alterações:
// Decla -> juntei ponto e virgula
// O Lista de Instruções está estranho (tem nested instructions)
// talvez deviamos distinguir entre as variaveis escalares e vetoriais
// no conjunto de instruções, é possivel identificar funções logo ao abrir usem duas chavetas
// juntar &no SCANI ?
// contar com os \n?
// rever as Exp
// pode dar erro quando se faz uma Atrib fora de FOR pq falta ;
// e quando se faz uma atribuiçao ao mesmo tempo que uma declaraçao? -> acrescentei produção (resolve tambem problema anterior)
// é necessario rever todos os sitios onde se deve inserir ou nao ;

%}

%union{
	char* var_name;
	int value;
	struct sVarAtr
	{
		char* var_name;
		int value;
		int size;
	} varAtr;
}

%token INT WHILE FOR IF ELSE RETURN VOID PRINTI SCANI TRUE FALSE DO END
%token var nomefuncao num

%type <var_name> var
%type <value> num
%type <varAtr> VarAtr
%type <varAtr> Atrib


%left '+' '-'
%left '*' '/' '%'
%left '&' '|'

%start Prog

%% 
Prog:		ListaDecla									{printf("START\n");}
			ListInstI									{printf("STOP\n");}
			;

ListInstI:	Inst ListInstI								
			| 
			;

ConjInst:	Inst										
			| '{' ListInst '}'							
			;

ListInst:	Inst ListInst								
			| Inst										
			;

Inst:		If											
			| While										
			| For										
			| Atrib	';'									
			| Printi';'									
			| Scani	';'									
			| DoWhile									
			;

VarAtr:		var											{$$.var_name=strdup($1); $$.size=1;}
			;

Atrib: 		VarAtr '=' Exp								{printf("STOREG %d\n", getMemAdd($1.var_name));}
			| VarAtr '+''+'								{printf("PUSHI 1\nPUSHG %d\nADD\nSTOREG %d\n",getMemAdd($1.var_name),
																									  getMemAdd($1.var_name));}
			| VarAtr 									{printf("PUSHI %d\n", getMemAdd($1.var_name));}
			 '[' Exp ']' '=' Exp 						{printf("STOREN\n");}
			;

ListaDecla: Decla ListaDecla 										
            | Funcao ListaDecla
            |
            ;

Decla:		INT var ';' 								{printf("PUSHI 0\n"); decVar($2, 1);}
			| INT var '[' num ']' ';'					{printf("PUSHN %d\n",$4); decVar($2, $4);}
			;

Printi:		PRINTI '(' Exp ')'							{printf("WRITEI\n");}
			;

Scani:		SCANI '(' VarAtr ')'						{printf("READ\nATOI\n\n");}
			;

If: 		IF TestExpL									{total++; push(s,total); printf("JZ endCond%d\n", get(s));}
			ConjInst									{printf("endCond%d\n", pop(s));}
			Else
			;

Else:		
			| ELSE ConjInst
			;

While:		WHILE 										{total++; push(s,total); printf("Cond%d: NOP\n", get(s));}
			TestExpL									{printf("JZ endCond%d\n", get(s));}
			ConjInst									{printf("JUMP Cond%d\nendCond%d\n", get(s), get(s)); pop(s);}
			;

DoWhile:	DO 											{total++; push(s,total); printf("Cond%d: NOP\n", get(s));}
			ConjInst WHILE TestExpL						{printf("JZ endCond%d\nJUMP Cond%d\nendCond%d: NOP\n",get(s) ,get(s) ,get(s)); pop(s);}
			;

For:		FOR ForHeader ConjInst 						{printf("JUMP Cond%dA\nendCond%d\n", get(s), get(s)); pop(s);}
			;

ForHeader:	'(' ForAtrib ';'							{total++; push(s,total); printf("Cond%d: NOP\n", get(s));}
			ExpL ';'									{printf("JZ endCond%d\nJUMP Cond%dB\nCond%dA: NOP\n", get(s), get(s), get(s));}
			ForAtrib ')'								{printf("JUMP Cond%d\nciclo%dB: NOP\n", get(s), get(s));}
			;

ForAtrib: 	Atrib										
			| 											
			;

Funcao:		Tipo var '(' ListaArg ')' ConjInst			
			;

Tipo:		VOID										
			| INT										
			;

ListaArg:	Tipo var									
			| ',' ListaArg								
			;

Exp:		 Exp '+' Exp								{printf("ADD\n");}
			| Exp '-' Exp								{printf("SUB\n");}
			| Exp '%' Exp   							{printf("MOD\n");}
			| Exp '*' Exp								{printf("MUL\n");}
			| Exp '/' Exp								{printf("DIV\n");}
			| '(' Exp ')'								
			| num										{printf("PUSHI %d\n", $1);}
			| VarAtr									{printf("PUSHG %d\n", getMemAdd($1.var_name));}
			| VarAtr '[' Exp ']'						{printf("PUSHI %d\nLOADN\n", getMemAdd($1.var_name));}

TestExpL:	'(' ExpL ')'										
			;

ExpL:		  Exp '=''=' Exp							{printf("EQUAL\n");}
     		| Exp '!''=' Exp							{printf("EQUAL\nPUSHI 0\nEQUAL\n");}
			| Exp '>''=' Exp  							{printf("SUPEQ\n");}
			| Exp '<''=' Exp							{printf("INFEQ\n");}
			| Exp '<' Exp 								{printf("INF\n");}
			| Exp '>' Exp								{printf("SUP\n");}
			| ExpL '&''&' ExpL
			| ExpL '|''|' ExpL
			;
%%

void yyerror(char *s){
    printf("Erro sintatico line %d: %s\n",ccLine,s);
}

void init()
{
	s = initStack();
	total = 0;
}

