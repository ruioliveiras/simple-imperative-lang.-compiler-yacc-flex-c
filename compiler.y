%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vmCompiler.h"
#include "stack.h"
#include "y.tab.h"


void yyerror(char *s);
extern ccLine;
FILE *f;
static int total;
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
    Type type;
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
%type <type> Tipo

%left '+' '-'
%left '*' '/' '%'
%left '&' '|'

%start Prog

%% 
// #################### PROGRAMA ###################################

Prog:       ListaDecla                                  
            ListaFun                                    {fprintf(f,"START\n");}
            ListInst                                    {fprintf(f,"STOP\n");}
            ;

ListaFun:   ListaFun Funcao 
            |
            ;

ListaDecla: ListaDecla Decla                            
            |
            ;

ListInst:   ListInst Inst                               
            | Inst                                      
            ;
// #################### FUNCAO #######################################

Funcao:     '#' Tipo var                        {decFun($2,$3);}
            '(' ListaArg ')'                    {decFunArgRefresh();fprintf(f,"%s:NOP\n",$3);}
            '{' ListaDecla ListInst '}'         {endDecFun();}          
            ;

ListaArg:   | ListaArg2 ;

ListaArg2:  Tipo var                            {decAddFunArg($1,$2);}
            | ListaArg2  ','  Tipo var          {decAddFunArg($3,$4);}
            ;


// #################### DECLARACAO ###################################

Decla:      INT var ';'                      {decVar($2, 1); fprintf(f,"PUSHI 0\n");}
            | INT var '[' num ']' ';'        {decVar($2, $4); fprintf(f,"PUSHN %d\n",$4);}
            ;

Tipo:       VOID                             {$$ = _VOID;}
            | INT                            {$$ = _INTS;}
            ;               

// ##################### INSTRUCAO ###################################

ConjInst:   |'{' ListInst '}';

Inst:       If                                          
            | While                                     
            | DoWhile
            | For                                       
            | Atrib ';'                                 
            | Printi';'                                 
            | Scani ';'                                 
            | RETURN Exp ';'                            {fprintf(f,"STOREL %d\n",decFunRetAddr());fprintf(f,"RETURN\n");}
            | ELSE                                      {yyerror("'Else' sem um 'If' anteriormente");}                              
            ;

VarAtr:     var                                         {Addr a = getAddr($1); $$.var_name=strdup($1); $$.size=1;}
            ;
// ###### ATRIBUIÇAO ######

Atrib:      VarAtr '=' Exp                              {Addr a = getAddr($1.var_name);
                                                        if(a.type == _INTS)
                                                            fprintf(f,"STORE%c %d\n",a.scope,a.addr);
                                                        else yyerror("Tipos incompatíveis");                                                            
                                                        }
            | VarAtr '+''+'                             {Addr a = getAddr($1.var_name);
                                                        if(a.type == _INTS)
                                                            fprintf(f,"PUSHI 1\nPUSH%c %d\nADD\nSTORE%c %d\n",
                                                                    a.scope,a.addr,a.scope,a.addr);
                                                        else yyerror("Tipos incompatíveis");                                                            
                                                        }
            | VarAtr                                    {Addr a = getAddr($1.var_name); 
                                                        fprintf(f,"PUSHI %d\n",a.addr);}
             '[' Exp ']' '=' Exp                        {fprintf(f,"STOREN\n");}
            ;

// ###### PRINT SCAN ######

Printi:     PRINTI '(' Exp ')'                          {fprintf(f,"WRITEI\n");}
            ;

Scani:      SCANI '(' VarAtr ')'                        {Addr a = getAddr($3.var_name);
                                                        fprintf(f,"READ\nATOI\nSTORE%c %d\n",a.scope,a.addr);}
            ;
// ###### IF THEN ELSE ######

If:         IF                                          {total++; push(s,total);}
            TestExpL                                    {fprintf(f,"JZ endCond%d\n", get(s));}
            ConjInst                                    {fprintf(f,"endCond%d\n", pop(s));}
            Else
            ;

Else:       | ELSE ConjInst ;

// ####### WHILE ###########

While:      WHILE                                       {total++; push(s,total); fprintf(f,"Cond%d: NOP\n", get(s));}
            TestExpL                                    {fprintf(f,"JZ endCond%d\n", get(s));}
            ConjInst                                    {fprintf(f,"JUMP Cond%d\nendCond%d\n", get(s), get(s)); pop(s);}
            ;

// ####### DO WHILE ###########

DoWhile:    DO                                          {total++; push(s,total); fprintf(f,"Cond%d: NOP\n", get(s));}
            ConjInst WHILE TestExpL                     {fprintf(f,"JZ endCond%d\nJUMP Cond%d\nendCond%d: NOP\n",get(s) ,get(s) ,get(s)); pop(s);}
            ;
    
// ####### FOR ###########

For:        FOR ForHeader ConjInst                      {fprintf(f,"JUMP Cond%dA\nendCond%d\n", get(s), get(s)); pop(s);}
            ;

ForHeader:  '(' ForAtrib ';'                            {total++; push(s,total); fprintf(f,"Cond%d: NOP\n", get(s));}
            ExpL ';'                                    {fprintf(f,"JZ endCond%d\nJUMP Cond%dB\nCond%dA: NOP\n", get(s), get(s), get(s));}
            ForAtrib ')'                                {fprintf(f,"JUMP Cond%d\nciclo%dB: NOP\n", get(s), get(s));}
            ;

ForAtrib:   Atrib | ;

// ############################### CALCULO DE EXPRESSOES ################################

Exp:         Exp '+' Exp                        {fprintf(f,"ADD\n");}
            | Exp '-' Exp                       {fprintf(f,"SUB\n");}
            | Exp '%' Exp                       {fprintf(f,"MOD\n");}
            | Exp '*' Exp                       {fprintf(f,"MUL\n");}
            | Exp '/' Exp                       {fprintf(f,"DIV\n");}
            | '(' Exp ')'                       
            | num                               {fprintf(f,"PUSHI %d\n", $1);}
            | VarAtr                            {Addr a = getAddr($1.var_name); 
                                                fprintf(f,"PUSH%c %d\n",a.scope,a.addr); }
            | VarAtr '[' Exp ']'                {Addr a = getAddr($1.var_name); 
                                                fprintf(f,"PUSH%cP\nADD\nPUSHI %d\nLOADN\n",a.scope,a.addr);}
            | var                               {expFun($1); fprintf(f,"nPUSHI 0\n");} // to the return
            '(' FunArgs')'                      {fprintf(f,"CALL %s\n",$1); fprintf(f, "POP %d\n",expFunNArgs());}
            ;


FunArgs:    | FunArgs2 ;
FunArgs2:   Exp                         {expFunNextArg(_INTS);}
            | FunArgs2 ',' Exp          {expFunNextArg(_INTS);}
            ;

TestExpL:   '(' ExpL ')'                                        
            ;

ExpL:         Exp '=''=' Exp                       {fprintf(f,"EQUAL\n");}
            | Exp '!''=' Exp                       {fprintf(f,"EQUAL\nPUSHI 0\nEQUAL\n");}
            | Exp '>''=' Exp                       {fprintf(f,"SUPEQ\n");}
            | Exp '<''=' Exp                       {fprintf(f,"INFEQ\n");}
            | Exp '<' Exp                          {fprintf(f,"INF\n");}
            | Exp '>' Exp                          {fprintf(f,"SUP\n");}
            | '(' ExpL ')'                         {fprintf(f,"PUSHI 1\nEQUAL\nJZ endCond%d\n", get(s));}
            '&''&' '(' ExpL ')'                    {fprintf(f,"PUSHI 1\nEQUAL\nJZ endCond%d\n", get(s));}
            | '(' ExpL ')' '|''|' '(' ExpL ')'     {fprintf(f,"ADD\nJZ endCond%d\n", get(s));}
        
%%

void yyerror(char *s){
    fprintf(stderr,"ERRO: Syntax LINHA: %d MSG: %s\n",ccLine,s);
    exit(0);
}

void init()
{
    s = initStack();
    total = 0;
    f = fopen("assembly.out", "w");
}
