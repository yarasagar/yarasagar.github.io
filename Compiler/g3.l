%{
#include <stdio.h>
#include <stdlib.h>
void yyerror();
#include "g3.h"
#include "y.tab.h"
%}

%%
[0-9]+	{yylval=(node *)malloc(sizeof(node));
	yylval->flag=0;
	yylval->val=atoi(yytext);
	yylval->right=NULL;
	yylval->left=NULL;
	return DIGIT;}
"write"	{yylval=(node *)malloc(sizeof(node));
	yylval->flag=3;
	yylval->s=yytext;
	yylval->right=NULL;
	yylval->left=NULL;
	return WRITE;}
"read"	{yylval=(node *)malloc(sizeof(node));
	yylval->flag=4;
	yylval->s=yytext;
	yylval->right=NULL;
	yylval->left=NULL;
	return READ;}
[+|*|=]	{yylval=(node *)malloc(sizeof(node));
	yylval->flag=1;
	yylval->op=*yytext;
	yylval->right=NULL;
	yylval->left=NULL;
	return *yytext;}
[a-z]	{yylval=(node *)malloc(sizeof(node));
	yylval->flag=2;
	yylval->op=*yytext;
	yylval->right=NULL;
	yylval->left=NULL;
	return VARIABLE;}
[\n|;|(|)]	return *yytext;
.
%%

int yywrap(){
return 1;
}
