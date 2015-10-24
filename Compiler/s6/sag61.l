%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "y.tab.h"
	#include "sag61.h"
%}

op	["+"|"*"|"("|")"|"<"|">"|"="|";"|","|\[|\]]
equal	==

%%
"read"	{return READ;}
"write"	{return WRITE;}
"if"	{return IF;}
"then"	{return THEN;}
"endif"	{return ENDIF;}
"while"	{return WHILE;}
"do"	{return DO;}
"endwhile"	{return ENDWHILE;}
"decl"	{return DECL;}
"enddecl"	{return ENDDECL;}
"integer"	{return INTEGER;}
[0-9]+	{yylval.val=atoi(yytext);return NUM;}
{equal}	{return EQUAL;}
{op}	{return *yytext;}
[a-z]+	{
			yylval.variable=malloc((yyleng+1)*sizeof(char ));
			strcpy(yylval.variable,yytext);
			return ID;
		}
[\t]	;
["\n"]	;
%%

yywrap(){
	return 1;
}