%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "y.tab.h"
	#include "sag10.h"
%}

op	["{"|"}"|"&"|"+"|"*"|\-|"/"|"%"|"("|")"|"="|";"|","|\[|\]]
equal	==

%%
"beg"	{return BEG;}
"end"	{return END;}
"main"	{return MAIN;}
"return"	{return RETURN;}

"read"	{return READ;}
"write"	{return WRITE;}
"if"	{return IF;}
"then"	{return THEN;}
"endif"	{return ENDIF;}
"else"	{return ELSE;}
"endelse"	{return ENDELSE;}
"while"	{return WHILE;}
"do"	{return DO;}
"endwhile"	{return ENDWHILE;}
"decl"	{return DECL;}
"enddecl"	{return ENDDECL;}
"integer"	{return INTEGER;}
"boolean"	{return BOOLEAN;}
"true"	{return TRUE;}
"false"	{return FALSE;}
"and"	{return AND;}
"or"	{return OR;}
"not"	{return NOT;}
[0-9]+	{yylval.val=atoi(yytext);return NUM;}
{equal}	{return EQUAL;}
{op}	{return *yytext;}
">"		{return GT;}
"<"		{return LT;}
">="	{return GE;}
"<="	{return LE;}
"!="	{return NE;}
[a-z]+	{
			yylval.variable=malloc((yyleng+1)*sizeof(char ));
			strcpy(yylval.variable,yytext);
			return ID;
		}
[\t]	;
["\n"]	{line++;};
%%

yywrap(){
	return 1;
}
