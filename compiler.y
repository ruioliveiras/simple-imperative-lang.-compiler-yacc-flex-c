%{
#include <stdio.h>
#include <string.h>
#include "compiler.h"
#include "y.tab.h"


void yyerror(char *s);
extern ccLine;
int conds[128];
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
			| RETURN Exp ';'
			| DoWhile									
			;

VarAtr:		var											{$$.var_name=strdup($1); $$.size=1;}
			;

Atrib: 		VarAtr '=' Exp								{printf("STOREG %d\n", getAddr($1.var_name));}
			| VarAtr '+''+'								{printf("PUSHI 1\nPUSHG %d\nADD\nSTOREG %d\n",getAddr($1.var_name),
																									  getAddr($1.var_name));}
			| VarAtr 									{printf("PUSHI %d\n", getAddr($1.var_name));}
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

If: 		IF TestExpL									{printf("JZ fimif\n");}
			ConjInst									{printf("fimif\n");}
			Else
			;

Else:
			| ELSE ConjInst
			;

While:		WHILE 										{printf("ciclo: NOP\n");}
			TestExpL									{printf("JZ fimciclo\n");}
			ConjInst									{printf("JUMP ciclo\nfimciclo\n");}
			;

DoWhile:	DO 											{printf("ciclo: NOP\n");}
			ConjInst WHILE TestExpL						{printf("JZ fimciclo\nJUMP ciclo\nfimciclo: NOP\n");}
			;

For:		FOR ForHeader ConjInst 						{printf("JUMP cicloA\nfimciclo\n");}
			;

ForHeader:	'(' ForAtrib ';'							{printf("ciclo: NOP\n");}
			TestExpL ';'								{printf("JZ fimciclo\nJUMP cicloB\ncicloA: NOP\n");}
			ForAtrib ')'								{printf("JUMP ciclo\ncicloB: NOP\n");}
			;

ForAtrib: 	Atrib										
			| 											
			;

Funcao:		'#'Tipo var '(' ListaArg ')'  ConjInst		{/*printf("##& Funcao:		Tipo nomefuncao '(' ListaArg ')' ConjInst ## P31\n");*/}
			;

Tipo:		VOID										
			| INT										
			;

ListaArg: 	
			| ListaArg2 
			;

ListaArg2:	Tipo var {printf("hey3\n");} 				
			| ListaArg2 {printf("hey4\n");} ',' {printf("hey5\n");}  Tipo var {printf("hey6\n");} 
			;

Exp:		 Exp '+' Exp								{printf("ADD\n");}
			| Exp '-' Exp								{printf("SUB\n");}
			| Exp '%' Exp   							{printf("MOD\n");}
			| Exp '*' Exp								{printf("MUL\n");}
			| Exp '/' Exp								{printf("DIV\n");}
			| '(' Exp ')'								
			| num										{printf("PUSHI %d\n", $1);}
			| VarAtr									{printf("PUSHG %d\n", getAddr($1.var_name));}
			| VarAtr '[' Exp ']'						{printf("PUSHGP\nADD\nPUSHI %d\nLOADN\n", getAddr($1.var_name));}
			| var '(' FunArgs')'
			;
FunArgs: 	
			| FunArgs2
			;

FunArgs2: 	 Exp 
			| FunArgs2 ',' Exp

TestExpL:	'(' ExpL ')'
			| TestExpL '&''&' TestExpL
			| TestExpL '|''|' TestExpL											
			;

ExpL:		  Exp '=''=' Exp							{printf("EQUAL\n");}
     		| Exp '!''=' Exp							{printf("EQUAL\nPUSHI 0\nEQUAL\n");}
			| Exp '>''=' Exp  							{printf("SUPEQ\n");}
			| Exp '<''=' Exp							{printf("INFEQ\n");}
			| Exp '<' Exp 								{printf("INF\n");}
			| Exp '>' Exp								{printf("SUP\n");}			
			;
%%

void yyerror(char *s){
    printf("Erro sintatico line %d: %s\n",ccLine,s);
}

