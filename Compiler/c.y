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
start: expr '\n'	{printf("\n");exit(1);}
	;
expr: NUM	{printf("%d ",yylval); }
	| expr '+' expr	{printf("+ ");}
	| expr '-' expr {printf("- ");}
	| expr '*' expr {printf("* ");}
	| expr '/' expr {printf("/ ");}
	| '(' expr ')' {printf("() ");}
	;
%%

void yyerror(){
printf("error");
}

int main(){
yyparse();
return 1;
}
