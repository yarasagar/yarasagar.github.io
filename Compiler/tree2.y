%{
#include <stdio.h>
#include <stdlib.h>
int x;
#include "lex.yy.c"
int eval(node *);
void yyerror();
%}

%token DIGIT
%left '+'
%left '*'

%%
start:	expr '\n'	{eval($1);printf("\n");exit(1);}
	;
expr:	expr '+' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| expr '*' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| DIGIT		{$$=$1;}
	;
%%

int eval(node *sag){
if(sag->flag==0)
printf("%d",sag->val);
else{
if(sag->op=='+'){
eval(sag->left);
printf("+");
eval(sag->right);
}
else if(sag->op=='*'){
eval(sag->left);
printf("*");
eval(sag->right);
}
}
}

void yyerror(){
printf("Error:");
}

int main(){
yyparse();
return 1;
}
