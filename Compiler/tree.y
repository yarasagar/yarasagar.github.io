%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
int n;
void yyerror();
int eval(node *);
%}

%token DIGIT
%left '+' '-'
%left '*' '/'

%%
start:	expr '\n'	{eval($1);printf("\n");exit(1);}	
	;
expr:	DIGIT	{$$=$1;}
	| expr '+' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| expr '-' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| expr '*' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| expr '/' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| '(' expr ')'	{$$=$2;}
	;
%%

void yyerror(){
printf("Error");
}

int eval(node *nd){
if(nd->flag==0)
printf("%d ",nd->val);
else{
if(nd->op=='+'){
printf("+ ");
eval(nd->left);
eval(nd->right);
}
else if(nd->op=='-'){
printf("- ");
eval(nd->left);
eval(nd->right);
}
else if(nd->op=='*'){
printf("* ");
eval(nd->left);
eval(nd->right);
}
else if(nd->op=='/'){
printf("/ ");
eval(nd->left);
eval(nd->right);
}
}
}

int main(){
yyparse();
return 1;
}
