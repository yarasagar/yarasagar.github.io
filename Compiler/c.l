%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
void yyerror();
%}

num [0-9]+

%%
{num}	{yylval=atoi(yytext);return NUM;}
[-|+|*|/|(|)|\n] return *yytext;
.	printf("error");
%%

int yywrap(){
return 1;
}
