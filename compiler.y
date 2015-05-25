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
%left  '&'

%start Prog

%% 
Prog:		ListaDecla									{printf("START\n");}
			ListInstI									{printf("STOP\n");}
			;

ListInstI:	Inst ListInstI								{/*printf("##& 			| Inst ListInstI ## P3\n");*/}
			| 
			;
ConjInst:	Inst										{/*printf("##& ConjInst:	Inst ## P4\n");*/}
			| '{' ListInst '}'							{/*printf("##& 			| '{' ListInst '}' ## P5\n");*/}
			;
ListInst:	Inst ListInst								{/*printf("##& ListInst:	Inst ListInst ## P6\n");*/}
			| Inst										{/*printf("##& 			| Inst ## P7\n");*/}
			;
Inst:		If											{/*printf("##& Inst:		If ## P8\n");*/}
			| While										{/*printf("##& 			| While ## P9\n");*/}
			| For										{/*printf("##& 			| For ## P10\n");*/}
			| Atrib	';'									{/*printf("##& 			| Atrib	';' ## P11\n");*/}
			| Printi';'									{/*printf("##& 			| Printi';' ## P12\n");*/}
			| Scani	';'									{/*printf("##& 			| Scani	';' ## P13\n");*/}
			| DoWhile									{/*printf("##& 			| Decla	';' ## P15\n");*/}
			;
VarAtr:		var											{$$.var_name=strdup($1); $$.size=1;}
			;

Atrib: 		VarAtr '=' Exp								{printf("STOREG %s\n",$1.var_name);}
			| VarAtr '+''+'								{printf("PUSHI 1\nPUSHG %s\nADD\nSTOREG %s\n",$1.var_name, $1.var_name);}
			| VarAtr 									{printf("PUSHI end(%s)\n", $1.var_name);}
			 '[' Exp ']' '=' Exp 						{printf("STOREN\n");}
			;

ListaDecla: Decla ListaDecla 										
            | Funcao ListaDecla
            |
            ;

Decla:		INT var ';' 								{printf("PUSHI 0 ------> int %s;\n", $2);}
			| INT var '[' num ']' ';'					{printf("PUSHN %d ------> int %s[%d];\n", $4, $2, $4);}
			;

Printi:		PRINTI '(' Exp ')'							{printf("WRITEI\n");}
			;
Scani:		SCANI '(' VarAtr ')'						{printf("READ\nATOI\n\n");}
			;
If: 		IF TestExpL									{printf("JZ fimif\n");}
			ConjInst									{printf("fimif\n");}
			;
While:		WHILE 										{printf("ciclo: NOP\n");}
			TestExpL									{printf("JZ fimciclo\n");}
			ConjInst									{printf("JUMP ciclo\nfimciclo\n");}
			;
DoWhile:	DO 											{printf("ciclo: NOP\n");}
			ConjInst WHILE TestExpL						{}
			;
For:		FOR ForHeader ConjInst 						{printf("JUMP cicloA\nfimciclo\n");}
			;
ForHeader:	'(' ForAtrib ';'							{printf("ciclo: NOP\n");}
			ExpL ';'									{printf("JZ fimciclo\nJUMP cicloB\ncicloA: NOP\n");}
			ForAtrib ')'								{printf("JUMP ciclo\ncicloB: NOP\n");}
			;
ForAtrib: 	Atrib										{/*printf("##& ForAtrib: 	Atrib ## P29\n");*/}
			| 											{/*printf("##& 			| ## P30\n");*/}
			;
Funcao:		'#'Tipo var '(' ListaArg ')' ConjInst		{/*printf("##& Funcao:		Tipo nomefuncao '(' ListaArg ')' ConjInst ## P31\n");*/}
			;
Tipo:		VOID										{/*printf("##& Tipo:		VOID ## P32\n");*/}
			| INT										{/*printf("##& 			| INT ## P33\n");*/}
			;
ListaArg:	Tipo var									{/*printf("##& ListaArg:	Tipo var ## P34\n");*/}
			| ',' ListaArg								{/*printf("##& 			| ',' ListaArg ## P35\n");*/}
			;
Exp:		 Exp '+' Exp								{printf("ADD\n");}
			| Exp '-' Exp								{printf("SUB\n");}
			| Exp '%' Exp   							{printf("MOD\n");}
			| Exp '*' Exp								{printf("MUL\n");}
			| Exp '/' Exp								{printf("DIV\n");}
			| '(' Exp ')'								{/*printf("##& 			| '(' Exp ')' ## P43\n");*/}
			| num										{printf("PUSHI %d\n",$1);}
			| VarAtr									{printf("PUSHG %s\n",$1.var_name);}
			| VarAtr '[' Exp ']'						{}
			| var'('ExpArgs')'							{printf("PUSHA %s\nCALL",$1);}
			| var'('')'									{printf("PUSHA %s\nCALL",$1);}

			;
ExpArgs:	Exp 										{}
			| ExpArg ',' Exp                            {}


TestExpL:	'(' ExpL ')'								{}
			;

ExpL:		ExpL '&''&' ExpL                            {printf("EQUAL\n");}
			| Exp '=''=' Exp							{printf("EQUAL\n");}
     		| Exp '!''=' Exp							{printf("EQUAL\n");}
			| Exp '>''=' Exp  							{printf("SUPEQ\n");}
			| Exp '<''=' Exp							{printf("INFEQ\n");}
			| Exp '<' Exp 								{printf("INF\n");}
			| Exp '>' Exp								{printf("SUP\n");}			
			;
%%

void yyerror(char *s){
    printf("Erro sintatico line %d: %s\n",ccLine,s);
}

