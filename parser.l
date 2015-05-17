%{
#include "y.tab.h"
#define PONTO '.'
#define PVIRG ';'
#define PE '('
#define PD ')'
#define VIRG ','
#define IGUAL '='

%}


%%
int 		{return(INT);}
if 			{return(IF);}
"=" 		{return(IGUAL);}
"."        	{return(PONTO);}
";"        	{return(PVIRG);}
"("        	{return(PE);}
")"        	{return(PD);}
","        	{return(VIRG);}
[a-zA-Z]+  	{return(var);}
[0-9]+     	{return(num);}
.|\n       	{ ; } 
%%

int yywrap()
{ return(1); }
