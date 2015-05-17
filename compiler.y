%{
#include <stdio.h>
#include "y.tab.h"

void yyerror(char *s);
// falta a variavel
// duvida na lista/conjunto de instruções
// alterações:
// Declaracao -> juntei ponto e virgula
// O Lista de Instruções está estranho (tem nested instructions)
// talvez deviamos distinguir entre as variaveis escalares e vetoriais
// no conjunto de instruções, é possivel identificar funções logo ao abrir usem duas chavetas
// juntar &no SCANI ?
// contar com os \n?
// rever as Exp
// pode dar erro quando se faz uma Atribuicao fora de FOR pq falta ;
// e quando se faz uma atribuiçao ao mesmo tempo que uma declaraçao? -> acrescentei produção (resolve tambem problema anterior)
// é necessario rever todos os sitios onde se deve inserir ou nao ;

%}


%token INT WHILE FOR IF ELSE RETURN VOID PRINTI SCANI TRUE FALSE DO
%token var nomefuncao num


%% 
Programa:					ConjuntoInstrucoes				{printf("P1\n");}
ConjuntoInstrucoes:			Instrucao						{printf("P2\n");}
							| '{' ListaInstrucoes '}'		{printf("P3\n");}
							| Funcao						{printf("P53\n");}
ListaInstrucoes:			Instrucao						{printf("P4\n");}
							| Instrucao ListaInstrucoes		{printf("P5\n");}
Declaracao:					INT VariavelAtr ';'				{printf("P6\n");}
							| INT Atribuicao ';'			{printf("P51\n");}
VariavelAtr:				var								{printf("P7\n");}
							| var '[' Exp ']'				{printf("P8\n");}
Instrucao:					If								{printf("P9\n");}
							| While							{printf("P10\n");}
							| For							{printf("P11\n");}
							| Atribuicao					{printf("P12\n");}
							| Printi						{printf("P13\n");}
							| Scani							{printf("P14\n");}
							| DoWhile						{printf("P15\n");}
							| Declaracao					{printf("P52\n");}
Atribuicao: 				var '=' Exp						{printf("P16\n");}
							| var '+''+'					{printf("P17\n");}
							| var '[' Exp ']' '=' Exp								{printf("P18\n");}
If: 						IF '(' ExpL ')' '{' ConjuntoInstrucoes '}'				{printf("P19\n");}
							| IF '(' ExpL ')' Instrucao								{printf("P20\n");}
While:						WHILE '(' ExpL ')' '{' ConjuntoInstrucoes '}'			{printf("P21\n");}
DoWhile:					DO '{' ConjuntoInstrucoes '}' WHILE '(' ExpL ')'		{printf("P22\n");}
For:						FOR '(' Atribuicao ';' ExpL ';' Atribuicao ')' '{' ConjuntoInstrucoes '}'		{printf("P23\n");}
							| FOR '(' ';' ExpL ';' Atribuicao ')' '{' ConjuntoInstrucoes '}'				{printf("P24\n");}
							| FOR '(' Atribuicao ';' ExpL ';' Atribuicao ')' ';'							{printf("P25\n");}
							| FOR '(' ';' ExpL ';' Atribuicao ')' ';'										{printf("P26\n");}
Printi:						PRINTI '(' Exp ')'										{printf("P27\n");}
Scani:						SCANI '(' VariavelAtr ')'								{printf("P28\n");}
Funcao:						Tipo nomefuncao '(' ListaArg ')' ConjuntoInstrucoes		{printf("P29\n");}
Tipo:						VOID					{printf("P30\n");}
							| INT					{printf("P31\n");}
ListaArg:					Tipo var				{printf("P32\n");}
							| ',' ListaArg			{printf("P33\n");}
Exp:						M Exp2					{printf("P34\n");}
Exp2: 												{printf("P35\n");}
							| '+' Exp				{printf("P36\n");}
							| '-' Exp				{printf("P37\n");}
M:							P M2					{printf("P38\n");}
M2: 												{printf("P39\n");}
							| '*' M					{printf("P40\n");}
							| '/' M					{printf("P41\n");}
P:							'(' Exp ')'				{printf("P42\n");}
							| num					{printf("P43\n");}
							| var					{printf("P44\n");}
ExpL:						var CLog Exp			{printf("P45\n");}
CLog:						'=''='					{printf("P46\n");}
							| '<''='				{printf("P47\n");}
							| '>''='				{printf("P48\n");}
							| '<'					{printf("P49\n");}
							| '>'					{printf("P50\n");}

%%

void yyerror(char *s){
    printf("Erro sintatico: %s\n",s);
}