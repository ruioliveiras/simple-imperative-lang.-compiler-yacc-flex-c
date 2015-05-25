%{
#include "y.tab.h"
#define PONTO '.'
#define PVIRG ';'
#define PE '('
#define PD ')'
#define VIRG ','
#define IGUAL '='

int ccLine = 1;

%}



%%

int         {return(INT);}
while       {return(WHILE);}
for         {return(FOR);}
if          {return(IF);}
else        {return(ELSE);}
return      {return(RETURN);}
void        {return(VOID);}
printi      {return(PRINTI);}
scani       {return(SCANI);}
true        {return(TRUE);}
false       {return(FALSE);}
do          {return(DO);}
\=	 		{return(IGUAL);}
\.        	{return(PONTO);}
\;        	{return(PVIRG);}
\(        	{return(PE);}
\)        	{return(PD);}
\{  	    {return('{');}
\}      	{return('}');}
\[ 	        {return('[');}
\]	        {return(']');}
\,        	{return(VIRG);}
\<	        {return('<');}
\>	        {return('>');}
\+	        {return('+');}
\-	        {return('-');}
\*	        {return('*');}
\/	        {return('/');}
\%	        {return('%');}
[a-zA-Z]+  	{yylval.var_name=strdup(yytext); return(var);}
[0-9]+     	{yylval.value=atoi(yytext); return(num);}
[\n]        { ccLine++;}
\/\/.*      { ; }     
.           { ; }
%%

int yywrap()
{ return(1); }