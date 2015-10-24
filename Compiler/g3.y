%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
int n,a[26];
void yyerror();
int eval(node *);
%}

%token DIGIT
%token VARIABLE
%token WRITE
%token READ
%left '+'
%left '*' 

%%
strat: slist '\n'	{n=eval($1);exit(1);}
	;
slist:	 slist stmt {$$=(node *)malloc(sizeof(node));
		$$->flag=7;
		$$->s=yytext;
		$$->right=$2;
		$$->left=$1;}
	 | stmt		{$$=$1;}
	;
stmt: 	VARIABLE '=' expr ';'	{$2->left=$1;$2->right=$3;$$=$2;/*a[$1->op-'a']=eval($3);*/}
	| WRITE '(' expr ')' ';'	{$1->left=$3;$$=$1;/*n=eval($2);printf("%d\n",n);*/}//exit(1);}
	| READ '(' VARIABLE ')' ';'	{$1->left=$3;$$=$1;}
	;
expr:	 DIGIT	{$$=$1;} 
	| expr '+' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| expr '*' expr	{$2->left=$1;$2->right=$3;$$=$2;}
	| '(' expr ')'	{$$=$2;}
	| VARIABLE	{$$=$1;}
	;
%%

void yyerror(){
printf("Error\n");
}

int eval(node *nd){
if(nd->flag==7){
eval(nd->left);
eval(nd->right);
return 1;
}
if(nd->flag==0)
return nd->val;
else if(nd->flag==3){
printf("%d\n",eval(nd->left));
return 1;
}
else if(nd->flag==4){
scanf("%d",&a[nd->left->op-'a']);
return 1;
}
else if(nd->flag==2){
return a[nd->op-'a'];
}
else{
if(nd->op=='+')
return (eval(nd->left)+eval(nd->right));
else if(nd->op=='*')
return (eval(nd->left)*eval(nd->right));
else if(nd->op=='=')
a[nd->left->op-'a']=eval(nd->right);
}
}

int main(){
yyparse();
return 1;
}
