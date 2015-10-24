%{
#include <stdio.h>
#include <stdlib.h>
void yyerror();
#include "g.h"
#include "y.tab.h"
%}

%%
[0-9]+	{yylval=(node *)malloc(sizeof(node));
	yylval->flag=0;
	yylval->val=atoi(yytext);
	yylval->right=NULL;
	yylval->left=NULL;
	return DIGIT;}
[+|-|*|/]	{yylval=(node *)malloc(sizeof(node));
	yylval->flag=1;
	yylval->op=*yytext;
	yylval->right=NULL;
	yylval->left=NULL;
	return *yytext;}
[\n]	return *yytext;
.	
%%

int yywrap(){
return 1;
}
