%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
int n,a[26],count=-1;
void yyerror();
FILE *fp;
int eval(node *);
int linecount=0;	
%}

%token DIGIT
%token VARIABLE
%token WRITE
%token READ
%left '+'
%left '*' 

%%
strat: slist 	{fprintf(fp,"START\n");n=codeGen($1);fprintf(fp,"HALT\n");exit(1);}
	;
slist:	 slist stmt {$$=(node *)malloc(sizeof(node));
		$$->flag=7;
		$$->s=yytext;
		$$->right=$2;
		$$->left=$1;}
	 | stmt		{$$=$1;}
	;
stmt: 	VARIABLE '=' expr ';'	{$2->left=$1;$2->right=$3;$$=$2;}
	| WRITE '(' expr ')' ';'	{$1->left=$3;$$=$1;}
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
printf("Error %d",linecount+1);
}

int getReg(){
	count++;
	return count;
}

int freeReg(){
	count--;
	return count;
}

int codeGen(node *nd){
	int r1,r2,loc;
	if(nd == NULL)
	;
	else if(nd->flag == 0){
		r1=getReg();
		fprintf(fp,"MOV R%d %d\n",r1,nd->val);
		return r1;
	}
	else if(nd->flag == 1){
		if(nd->op == '+'){
			r1=codeGen(nd->left);
			r2=codeGen(nd->right);
			fprintf(fp,"ADD R%d R%d\n",r1,r2);
			freeReg();
			return r1;
		}
		else if(nd->op == '*'){
			r1=codeGen(nd->left);
			r2=codeGen(nd->right);
			fprintf(fp,"MUL R%d R%d\n",r1,r2);
			freeReg();
			return r1;
		}
		else if(nd->op == '='){
			r1=codeGen(nd->right);
			loc=nd->left->op-'a';
			fprintf(fp,"MOV [%d] R%d\n",loc,r1);
			freeReg();
			return r1;
		}
	}
	else if(nd->flag == 2){
		r1=getReg();
		loc=nd->op-'a';
		fprintf(fp,"MOV R%d [%d]\n",r1,loc);
		return r1;
	}	
	else if(nd->flag == 3){
		r1=codeGen(nd->left);
		fprintf(fp,"OUT R%d\n",r1);
		return r1;
	}
	else if(nd->flag == 4){
		r1=codeGen(nd->left);
		loc=nd->left->op-'a';
		fprintf(fp,"IN R%d\n",r1);
		fprintf(fp,"MOV [%d] R%d\n",loc,r1);
		return r1;
	}
	else if(nd->flag ==7){
		codeGen(nd->left);
		codeGen(nd->right);
		
	}	
}

/*int eval(node *nd){
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
if(nd->op=='+'){
	return (eval(nd->left)+eval(nd->right));
}
else if(nd->op=='*'){
	return (eval(nd->left)*eval(nd->right));
}
else if(nd->op=='='){	
	a[nd->left->op-'a']=eval(nd->right);
}
}
}*/

int main(int argc,char *argv[]){
	yyin=fopen(argv[1],"r");
	fp=fopen("out.txt","w+");
	yyparse();
	fclose(yyin);
	return 1;
}
