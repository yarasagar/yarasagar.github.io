%{
#include "lex.yy.c"
#include <stdio.h>
#include <stdlib.h>
void yyerror();
%}

%token NUM
%left '+' '-'
%left '*' '/'

%%
start: expr '\n'	{printf("%d\n",$1);exit(1);}
	;
expr: NUM
	| expr '+' expr	{$$=$1+$3;}
	| expr '-' expr {$$=$1-$3;}
	| expr '*' expr {$$=$1*$3;}
	| expr '/' expr {$$=$1/$3;}
	| '(' expr ')' {$$=$2;}
	;
%%

void yyerror(){
printf("error");
}

int main(){
yyparse();
return 1;
}
