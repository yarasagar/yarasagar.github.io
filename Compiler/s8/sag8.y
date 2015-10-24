%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lex.yy.c"
	#define ID_ARRAY 1003
	int vartype;
	struct tnode *makenode(int ,int ,char *,int ,struct tnode *,struct tnode *,struct tnode *);
	void typechecking(struct tnode *,struct tnode *,struct tnode *,struct tnode *);
	struct gnode *head=NULL;
%}

%union {
	int val;
	char *variable;
	struct tnode *ptr;
}

%token <variable> ID
%token <val> NUM
%token <val> READ
%token <val> WRITE
%token <val> IF
%token <val> THEN
%token <val> ENDIF
%token <val> WHILE
%token <val> DO
%token <val> ENDWHILE
%token <val> EQUAL
%token <val> DECL
%token <val> ENDDECL
%token <val> INTEGER
%token <val> BOOLEAN
%token <val> VOID
%token <val> TRUE
%token <val> FALSE
%token <val> AND
%token <val> OR
%token <val> NOT
%token <val> GT
%token <val> LT
%token <val> GE
%token <val> NE
%token <val> LE

%type <ptr> slist
%type <ptr> stmt
%type <ptr> expr
%type <ptr> var
%type <ptr> Type

%left '%'
%left '+' '-'
%left '*' '/'
%nonassoc GT GE LT LE EQUAL NE AND OR NOT

%%
pgm:	gdecl slist		{evaluate($2);return 1;}
		;
gdecl:	DECL dlist ENDDECL
		;
dlist:	dlist decl
		| decl
		;
decl:	 Type ilist ';'
		;
Type:	INTEGER		{vartype=INTEGER;}
		| BOOLEAN 	{vartype=BOOLEAN;}
		;		
ilist:	ilist ',' ID  	{ginstall($3,vartype,1);}
		| ilist ',' ID '[' NUM ']'	{ginstall($3,vartype,$5);}
		| ID 			{ginstall($1,vartype,1);}
		| ID '[' NUM ']'	{ginstall($1,vartype,$3);}
		;
slist:	slist stmt	{$$=makenode(VOID,3,NULL,-1,$1,NULL,$2);}
		| stmt	{$$=$1;}
		;
stmt:	var '=' expr ';'		{$$=makenode(VOID,'=',NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| READ '(' var ')' ';'	{$$=makenode(VOID,READ,NULL,-1,$3,NULL,NULL); typechecking($$,$$->left,$$->middle,$$->right);}
		| WRITE '(' expr ')' ';'	{$$=makenode(VOID,WRITE,NULL,-1,$3,NULL,NULL); typechecking($$,$$->left,$$->middle,$$->right);}
		| IF '(' expr ')' THEN slist ENDIF ';'	{$$=makenode(VOID,IF,NULL,-1,$3,NULL,$6); typechecking($$,$$->left,$$->middle,$$->right);}
		| WHILE '(' expr ')' DO slist ENDWHILE ';'	{$$=makenode(VOID,WHILE,NULL,-1,$3,NULL,$6); typechecking($$,$$->left,$$->middle,$$->right);}
		;
expr:	expr '+' expr	{$$=makenode(INTEGER,'+',NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr '-' expr	{$$=makenode(INTEGER,'-',NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr '/' expr	{$$=makenode(INTEGER,'/',NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr '*' expr	{$$=makenode(INTEGER,'*',NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr '%' expr	{$$=makenode(INTEGER,'%',NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| '(' expr ')'	{$$=$2;}
		| expr GT expr		{$$=makenode(BOOLEAN,GT,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr LT expr		{$$=makenode(BOOLEAN,LT,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr EQUAL expr	{$$=makenode(BOOLEAN,EQUAL,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr GE expr		{$$=makenode(BOOLEAN,GE,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr LE expr		{$$=makenode(BOOLEAN,LE,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr NE expr		{$$=makenode(BOOLEAN,NE,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr AND expr		{$$=makenode(BOOLEAN,AND,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| expr OR expr		{$$=makenode(BOOLEAN,OR,NULL,-1,$1,NULL,$3); typechecking($$,$$->left,$$->middle,$$->right);}
		| NOT expr		{$$=makenode(BOOLEAN,NOT,NULL,-1,$2,NULL,NULL); typechecking($$,$$->left,$$->middle,$$->right);}
		| TRUE			{$$=makenode(BOOLEAN,TRUE,NULL,-1,NULL,NULL,NULL);}
		| FALSE			{$$=makenode(BOOLEAN,FALSE,NULL,-1,NULL,NULL,NULL);}
		| NUM	{$$=makenode(INTEGER,NUM,NULL,$1,NULL,NULL,NULL);}
		| var 	{$$=$1;}
		;
var:	ID 			{struct gnode *temp=glookup($1);$$=makenode(temp->type,ID,$1,-1,NULL,NULL,NULL);}
		| ID '[' expr ']'		{struct gnode *temp=glookup($1);$$=makenode(temp->type,ID_ARRAY,$1,evaluate($3),$3,NULL,NULL); typechecking($$,$$->left,$$->middle,$$->right);}
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

void typechecking(struct tnode *tree,struct tnode *le,struct tnode *midd,struct tnode *rig){
	if(tree->nodetype == '+' || tree->nodetype == '-' || tree->nodetype == '*' || tree->nodetype == '/' || tree->nodetype == '%'){
		if(le->type == INTEGER && rig->type == INTEGER)
			;
		else{		
			printf("Error in Arithmetic exp");
			exit(1);
			}
	}
	else if(tree->nodetype == GT || tree->nodetype == GE || tree->nodetype == LT || tree->nodetype == LE || tree->nodetype == NE || tree->nodetype == EQUAL){
		if(le->type == INTEGER && rig->type == INTEGER)
		;
		else{
			printf("Error in Relational exp");
			exit(1);
			}
	}
	else if(tree->nodetype == AND || tree->nodetype == OR){
		if(le->type ==  BOOLEAN && rig->type == BOOLEAN)
		;
		else{
			printf("Error in and ,or exp");
			exit(1);
			}
	}
	else if(tree->nodetype == NOT){
		if(le->type==BOOLEAN)
		;
		else{
			printf("Error in not");
			exit(1);
			}
	}
	else if(tree->nodetype == ID_ARRAY){
		struct gnode *tem;
		tem=glookup(tree->name);
			if(tem->size > tree->value && tree->value >-1)
			;
			else{
				printf("Error in array");
				exit(1);	
				}
	}
	else if(tree->nodetype == IF){
		if(le->type == BOOLEAN && rig->type == VOID)
		;
		else{
			printf("Error in if exp");						
			exit(1);
			}
	}
	else if(tree->nodetype == WHILE){
		if(le->type == BOOLEAN && rig->type == VOID)
		;
		else{
			printf("Error in while exp");
			exit(1);
			}
	}
	else if(tree->nodetype == READ){
		if(le->type == INTEGER)
		;
		else{
			printf("Error in read exp");
			exit(1);
			}
	}
	else if(tree->nodetype == WRITE){
		if(le->type == INTEGER)
		;
		else{
			printf("Error in write exp");
			exit(1);
			}
	}
	else if(tree->nodetype == '='){
		if(le->type == INTEGER && rig->type == INTEGER)
		;
		else if(le->type == BOOLEAN && rig->type == BOOLEAN)
		;
		else{
			printf("Error in = exp");
			exit(1);
			}
	}
}

int main(int argc,char *argv[]){
	yyin=fopen(argv[1],"r");
	yyparse();
	fclose(yyin);
	return 1;
}