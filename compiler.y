%{
#include <stdio.h>
#include "y.tab.h"

void yyerror(char *s);
extern ccLine;
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


%token INT WHILE FOR IF ELSE RETURN VOID PRINTI SCANI TRUE FALSE DO END
%token var nomefuncao num

%left '+' '-'
%left '*' '/' '%'

%% 
Prog: 		ListInstI END					{printf("##& Prog: 		ListInstI END ## P1\n");}
			;
ListInstI:	Funcao ListInstI				{printf("##& ListInstI:	Funcao ListInstI ## P2\n");}
			| Inst ListInstI				{printf("##& 			| Inst ListInstI ## P3\n");}
			| 
			;
ConjInst:	Inst							{printf("##& ConjInst:	Inst ## P4\n");}
			| '{' ListInst '}'				{printf("##& 			| '{' ListInst '}' ## P5\n");}
			;
ListInst:	Inst ListInst					{printf("##& ListInst:	Inst ListInst ## P6\n");}
			| Inst							{printf("##& 			| Inst ## P7\n");}
			;
Inst:		If								{printf("##& Inst:		If ## P8\n");}
			| While							{printf("##& 			| While ## P9\n");}
			| For							{printf("##& 			| For ## P10\n");}
			| Atrib	';'						{printf("##& 			| Atrib	';' ## P11\n");}
			| Printi';'						{printf("##& 			| Printi';' ## P12\n");}
			| Scani	';'						{printf("##& 			| Scani	';' ## P13\n");}
			| DoWhile						{printf("##& 			| DoWhile ## P14\n");}
			| Decla	';'						{printf("##& 			| Decla	';' ## P15\n");}
			;
VarAtr:		var								{printf("##& VarAtr:		var ## P16\n");}
			| var '[' Exp ']'				{printf("##& 			| var '[' Exp ']' ## P17\n");}
			;
Atrib: 		VarAtr '=' Exp					{printf("##& Atrib: 		VarAtr '=' Exp ## P18\n");}
			| VarAtr '+''+'					{printf("##& 			| VarAtr '+''+' ## P19\n");}
			;
Decla:		INT VarAtr 						{printf("##& Decla:		INT VarAtr ## P20\n");}
			| INT Atrib 					{printf("##& 			| INT Atrib ## P21\n");}
			;
Printi:		PRINTI '(' Exp ')'							{printf("##& Printi:		PRINTI '(' Exp ')' ## P22\n");}
			;
Scani:		SCANI '(' VarAtr ')'						{printf("##& Scani:		SCANI '(' VarAtr ')' ## P23\n");}
			;
If: 		IF TestExpL ConjInst						{printf("##& If: 		IF TestExpL ConjInst ## P24\n");}
			;
While:		WHILE TestExpL ConjInst						{printf("##& While:		WHILE TestExpL ConjInst ## P25\n");}
			;
DoWhile:	DO ConjInst WHILE TestExpL					{printf("##& DoWhile:	DO ConjInst WHILE TestExpL ## P26\n");}
			;
For:		FOR ForHeader ConjInst 						{printf("##& For:		FOR ForHeader ConjInst ## P27\n");}
			;
ForHeader:	'(' ForAtrib ';' ExpL ';' ForAtrib ')'		{printf("##& ForHeader:	'(' ForAtrib ';' ExpL ';' ForAtrib ')' ## P28\n");}
			;
ForAtrib: 	Atrib										{printf("##& ForAtrib: 	Atrib ## P29\n");}
			| 											{printf("##& 			| ## P30\n");}
			;
Funcao:		Tipo nomefuncao '(' ListaArg ')' ConjInst	{printf("##& Funcao:		Tipo nomefuncao '(' ListaArg ')' ConjInst ## P31\n");}
			;
Tipo:		VOID					{printf("##& Tipo:		VOID ## P32\n");}
			| INT					{printf("##& 			| INT ## P33\n");}
			;
ListaArg:	Tipo var				{printf("##& ListaArg:	Tipo var ## P34\n");}
			| ',' ListaArg			{printf("##& 			| ',' ListaArg ## P35\n");}
			;
Exp:		 Exp '+' Exp			{printf("##& 			| Exp '+' Exp ## P38\n");}
			| Exp '-' Exp			{printf("##& 			| Exp '-' Exp ## P39\n");}
			| Exp '*' Exp			{printf("##& 			| Exp '*' Exp ## P40\n");}
			| Exp '/' Exp			{printf("##& 			| Exp '/' Exp ## P41\n");}
			| Exp '%' Exp   		{printf("##& 			| Exp 'mod' Exp ## P42\n");}
			| '(' Exp ')'			{printf("##& 			| '(' Exp ')' ## P43\n");}
			| num					{printf("##& Exp:		num ## P36\n");}
			| VarAtr					{printf("##& 			| var ## P37\n");}
TestExpL:	'(' ExpL ')'			{printf("##& TestExpL:	'(' ExpL ')' ## P44\n");}
			;
ExpL:		Exp '=''=' Exp			{printf("##& ExpL:		Exp '=''=' Exp ## P45\n");}
     		| Exp '!''=' Exp		{printf("##&      		| Exp '!''=' Exp ## P46\n");}
			| Exp '>''=' Exp  		{printf("##& 			| Exp '>''=' Exp ## P47\n");}
			| Exp '<''=' Exp		{printf("##& 			| Exp '<''=' Exp ## P48\n");}
			| Exp '<' Exp 			{printf("##& 			| Exp '<' Exp ## P49\n");}
			| Exp '>' Exp			{printf("##& 			| Exp '>' Exp ## P50\n");}			
			;
%%

void yyerror(char *s){
    printf("Erro sintatico line %d: %s\n",ccLine,s);
}