%{
#include<stdio.h>
#include"y.tab.h"

%}

%token NOTAS
%token pal num

%% 
Pauta:      Cabeca Corpo '.'       {printf("Reconhecido mano!\n");}
Cabeca:     NOTAS                  {printf("Hey1\n");}
Corpo:      Aluno Alunos           {printf("Hey2\n");}
Aluno:      IdAl '(' Notas ')'
Alunos:     
          | ';' Corpo
IdAl:       pal
Notas:      Nota LstNotas
Nota:       num
LstNotas:   
          | ',' Notas


%%

void yyerror(char *s){
    printf("Erro sintatico: %s\n",s);
}
