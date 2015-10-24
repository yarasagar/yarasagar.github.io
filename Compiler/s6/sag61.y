%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lex.yy.c"
	#define ID_ARRAY 5
	struct tnode *makenode(int ,int ,char *,int ,struct tnode *,struct tnode *,struct tnode *);
	struct gnode *head=NULL;
%}

%union {
	int val;
	char *variable;
	struct tnode *ptr;
}

%token <variable> ID;
%token <val> NUM;
%token <val> READ;
%token <val> WRITE;
%token <val> IF;
%token <val> THEN;
%token <val> ENDIF;
%token <val> WHILE;
%token <val> DO;
%token <val> ENDWHILE;
%token <val> EQUAL;
%token <val> DECL;
%token <val> ENDDECL;
%token <val> INTEGER;

%type <ptr> slist
%type <ptr> stmt
%type <ptr> expr
%type <ptr> var

%left '+'
%left '*'
%left '>'
%left '<'
%nonassoc '='
%nonassoc EQUAL

%%
pgm:	gdecl slist		{evaluate($2);return 1;}
		;
gdecl:	DECL dlist ENDDECL
		;
dlist:	dlist decl
		| decl
		;
decl:	INTEGER ilist ';'
		;
ilist:	ilist ',' ID  	{ginstall($3,INTEGER,1);}
		| ilist ',' ID '[' NUM ']'	{ginstall($3,INTEGER,$5);}
		| ID 			{ginstall($1,INTEGER,1);}
		| ID '[' NUM ']'	{ginstall($1,INTEGER,$3);}
		;
slist:	slist stmt	{$$=makenode(INTEGER,3,NULL,-1,$1,NULL,$2);}
		| stmt	{$$=$1;}
		;
stmt:	var '=' expr ';'		{$$=makenode(INTEGER,'=',NULL,-1,$1,NULL,$3);}
		| READ '(' var ')' ';'	{$$=makenode(INTEGER,READ,NULL,-1,$3,NULL,NULL);}
		| WRITE '(' expr ')' ';'	{$$=makenode(INTEGER,WRITE,NULL,-1,$3,NULL,NULL);}
		| IF '(' expr ')' THEN slist ENDIF ';'	{$$=makenode(INTEGER,IF,NULL,-1,$3,NULL,$6);}
		| WHILE '(' expr ')' DO slist ENDWHILE ';'	{$$=makenode(INTEGER,WHILE,NULL,-1,$3,NULL,$6);}
		;
expr:	expr '+' expr	{$$=makenode(INTEGER,'+',NULL,-1,$1,NULL,$3);}
		| expr '*' expr	{$$=makenode(INTEGER,'*',NULL,-1,$1,NULL,$3);}
		| '(' expr ')'	{$$=$2;}
		| expr '<' expr		{$$=makenode(INTEGER,'<',NULL,-1,$1,NULL,$3);}
		| expr '>' expr		{$$=makenode(INTEGER,'>',NULL,-1,$1,NULL,$3);}
		| expr EQUAL expr	{$$=makenode(INTEGER,EQUAL,NULL,-1,$1,NULL,$3);}
		| NUM	{$$=makenode(INTEGER,NUM,NULL,$1,NULL,NULL,NULL);}
		| var 	{$$=$1;}
		;
var:	ID 			{$$=makenode(INTEGER,ID,$1,-1,NULL,NULL,NULL);}
		| ID '[' NUM ']'		{$$=makenode(INTEGER,ID_ARRAY,$1,$3,NULL,NULL,NULL);}
%%

struct tnode *makenode(int typ,int nodetyp,char *nam,int valu,struct tnode *lef,struct tnode *middl,struct tnode *righ){
	struct tnode *temp;
	temp=(struct tnode *)malloc(sizeof(struct tnode));
	temp->type=typ;
	temp->nodetype=nodetyp;
	temp->name=nam;
	temp->value=valu;
	temp->left=lef;
	temp->middle=middl;
	temp->right=righ;
	return temp;
}
struct gnode * glookup(char *nam){
	struct gnode *tem=head;
	while(tem!=NULL){
		if(strcmp(tem->name,nam)==0)
		break;
		else
		tem=tem->next;
	}
	if(tem==NULL){
		printf("Not IN Entry");
		exit(1);
	}
	return tem;
}
yyerror(){
	printf("Error\n");
}
void ginstall(char *nam,int typ,int siz){
	struct gnode *tem=head;
	if(tem==NULL){
		head=malloc(sizeof(struct gnode));
		tem=head;
	}
	else{
		while(tem->next!=NULL){
			tem=tem->next;
		}
		tem->next=malloc(sizeof(struct gnode));
		tem=tem->next;
	}
	tem->name=nam;
	tem->type=typ;
	tem->size=siz;
	tem->binding=malloc(siz*sizeof(struct gnode));
	tem->next=NULL;
}

int evaluate(struct tnode *t){
	struct gnode *temp;
	if(t->nodetype == NUM)
	return t->value;
	else if(t->nodetype == READ){
		temp=glookup(t->left->name);
		if(temp->size == 1)
			scanf("%d",temp->binding);
		else
			scanf("%d",&temp->binding[t->left->value]);	
		return 1;
	}
	else if(t->nodetype == WRITE){
		printf("%d",evaluate(t->left));
		return 1;
	}
	else if(t->nodetype == IF){
		if(evaluate(t->left)){
			evaluate(t->right);
		}
		return 1;
	}
	else if(t->nodetype == WHILE){
		while(evaluate(t->left)){
			evaluate(t->right);
		}
		return 1;
	}
	else if(t->nodetype == ID){
		temp=glookup(t->name);
		return *(temp->binding);
	}
	else if(t->nodetype == ID_ARRAY){
		temp=glookup(t->name);
		return temp->binding[t->value];	
	}
	else if(t->nodetype == '+'){
		return (evaluate(t->left) + evaluate(t->right));
	}
	else if(t->nodetype == '*'){
		return (evaluate(t->left) * evaluate(t->right));
	}
	else if(t->nodetype == '>'){
		return (evaluate(t->left) > evaluate(t->right));
	}
	else if(t->nodetype == '<'){
		return (evaluate(t->left) < evaluate(t->right));
	}
	else if(t->nodetype == EQUAL){
		return (evaluate(t->left) == evaluate(t->right));
	}
	else if(t->nodetype == 3){
		evaluate(t->left);
		evaluate(t->right);
		return 1;
	}
	else if(t->nodetype == '='){
		temp=glookup(t->left->name);
		if(temp->size == 1)
			*(temp->binding)=evaluate(t->right);
		else
			temp->binding[t->left->value]=evaluate(t->right);
	}
}

int main(int argc,char *argv[]){
	yyin=fopen(argv[1],"r");
	yyparse();
	fclose(yyin);
	return 1;
}