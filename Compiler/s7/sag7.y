%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lex.yy.c"
	#define ID_ARRAY 100
	int vartype,count=0;
	FILE *fp;
	int reg=-1,lab=-1;
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
pgm:	gdecl slist		{fprintf(fp,"START\n");codeGen($2);fprintf(fp,"HALT\n");return 1;}
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
var:	ID 			{struct gnode *temp=glookup($1);$$=makenode(temp->type,ID,$1,1,NULL,NULL,NULL);}
		| ID '[' expr ']'		{struct gnode *temp=glookup($1);$$=makenode(temp->type,ID_ARRAY,$1,-1,$3,NULL,NULL); }
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
		return NULL;
	}
	return tem;
}
yyerror(){
	printf("Error\n");
	return 1;
}
void ginstall(char *nam,int typ,int siz){
	struct gnode *tem=head;
	/*if(glookup(nam) != NULL){
		printf("Already exist");
		exit(1);
		}
	*/if(tem==NULL){
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
	tem->binding=count;
	count=count+siz;
	tem->next=NULL;
}

int getReg(){
	reg++;
	return reg;
}

int freeReg(){
	reg--;
	return reg;
}

int getLabel(){
	lab++;
	return lab;
}

int getBinding(struct tnode *te){
	int loc,r1;
	struct gnode *tem;
	tem=glookup(te->name);
	loc=tem->binding;
	r1=getReg();	
	fprintf(fp,"MOV R%d,%d\n",r1,loc);
	return r1;
}

int codeGen(struct tnode *t){
	int r1,r2,l1,l2,r3,r4;
	struct gnode *temp;
	if(t == NULL)
		;
	else if(t->nodetype == NUM){
		r1=getReg();
		fprintf(fp,"MOV R%d %d\n",r1,t->value);
		return r1;
	}
	else if(t->nodetype == READ){
		r1=getReg();		
		if(t->left->left == NULL){
			fprintf(fp,"IN R%d\n",r1);
			r2=getBinding(t->left);
			fprintf(fp,"MOV [R%d],R%d\n",r2,r1);
			freeReg();
			freeReg();
		}
		else {	
			r2=codeGen(t->left->left);
			r3=getBinding(t->left);
			fprintf(fp,"IN R%d\n",r1);
			fprintf(fp,"ADD R%d,R%d\n",r2,r3);	
			fprintf(fp,"MOV [R%d],R%d\n",r2,r1);
			freeReg();
			freeReg();
			freeReg();
		}
	}
	else if(t->nodetype == WRITE){
		r1=codeGen(t->left);
		fprintf(fp,"OUT R%d\n",r1);
		freeReg();
	}
	else if(t->nodetype == ID){
		r1=getReg();
		r2=getBinding(t);
		fprintf(fp,"MOV R%d,[R%d]\n",r1,r2);
		freeReg();
		return r1;
	}
	else if(t->nodetype == '='){
		r1=codeGen(t->right);
		if(t->left->left == NULL){
			r2=getBinding(t->left);
			fprintf(fp,"MOV [R%d],R%d\n",r2,r1);
			freeReg();
			freeReg();
		}
		else {	
			r2=codeGen(t->left->left);
			r3=getBinding(t->left);
			fprintf(fp,"ADD R%d,R%d\n",r2,r3);	
			fprintf(fp,"MOV [R%d],R%d\n",r2,r1);
			freeReg();
			freeReg();
			freeReg();
		}
	}
	else if(t->nodetype == ID_ARRAY){
		r1=codeGen(t->left);
		r2=getBinding(t);	
		fprintf(fp,"ADD R%d,R%d\n",r2,r1);
		fprintf(fp,"MOV R%d,[R%d]\n",r1,r2);
		freeReg();
		return r1;
	}
	else if(t->nodetype == '+'){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"ADD R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}	
	else if(t->nodetype == '-'){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
				fprintf(fp,"SUB R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == '*'){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"MUL R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == '/'){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"DIV R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == '%'){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"MOD R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == GT){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"GT R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == LT){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"LT R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == GE){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"GE R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == LE){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"LE R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == NE){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"NE R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == EQUAL){
			r1=codeGen(t->left);
			r2=codeGen(t->right);
			fprintf(fp,"EQ R%d R%d\n",r1,r2);
			freeReg();
			return r1;
	}
	else if(t->nodetype == TRUE ){
		r1=getReg();
		fprintf(fp,"MOV R%d 1\n",r1);
		return r1;
	}
	else if(t->nodetype == FALSE ){
		r1=getReg();
		fprintf(fp,"MOV R%d 0\n",r1);
		return r1;
	}
	else if(t->nodetype == AND){
		r1=codeGen(t->left);
		r2=codeGen(t->right);
		fprintf(fp,"MUL R%d R%d\n",r1,r2);
		freeReg();
		return r1;
	}
	else if(t->nodetype == OR){
		r1=codeGen(t->left);
		r2=codeGen(t->right);
		fprintf(fp,"ADD R%d,R%d\n",r1,r2);
		fprintf(fp,"MOV R%d,1\n",r2);
		fprintf(fp,"ADD R%d,R%d\n",r1,r2);
		fprintf(fp,"MOV R%d,2\n",r2);
		fprintf(fp,"DIV R%d,R%d\n",r1,r2);
		freeReg();	
		return r1;
	}
	else if(t->nodetype == NOT){
		r1=codeGen(t->left);
		r2=getReg();
		fprintf(fp,"MOV R%d,0\n",r2);
		fprintf(fp,"EQ R%d,R%d\n",r1,r2);
		freeReg();
		return r1;

	}
/*	else if(t->nodetype == FUNCTION){
		int y=reg;
		int i=y;
		while(i>=0){
			fprintf(fp,"PUSH R%d\n",i);
			freeReg(i);
			i--;
		}
		argpush(t->ArgList);
		r3=getReg();
		fprintf(fp,"PUSH R%d\n",r3);
		freeReg();
		fprintf(fp,"CALL %s\n",t->name);
		i=0;
		while(i<=y){
			r1=getReg();
			i++;
		}
		r3=getReg();
		fprintf(fp,"POP R%d\n",r3);
		argpop(t->ArgList);
		i=0;
		while(i<=y){
			fprintf(fp,"POP R%d\n",i);
			i++;
		}
		return r3;
	}
*/	else if(t->nodetype == 3){
		codeGen(t->left);
		codeGen(t->right);
	}
	else if(t->nodetype == 6){
		codeGen(t->left);
		codeGen(t->right);
	}
	else if(t->nodetype == IF){
		l1=getLabel();
		r1=codeGen(t->left);
		fprintf(fp,"JZ R%d l%d\n",r1,l1);
		r1=codeGen(t->right);
		fprintf(fp,"l%d:\n",l1);
		freeReg();
	}
/*	else if(t->nodetype == ELSE){
		l1=getLabel();
		l2=getLabel();
		r1=codeGen(t->left);
		fprintf(fp,"JZ R%d l%d\n",r1,l1);
		r1=codeGen(t->right);
		fprintf(fp,"JMP l%d\n",l2);
		fprintf(fp,"l%d:\n",l1);
		r2=codeGen(t->middle);
		fprintf(fp,"l%d:\n",l2);
		freeReg();
		freeReg();
	}
*/	else if(t->nodetype == WHILE){
		l1=getLabel();
		l2=getLabel();
		fprintf(fp,"l%d:\n",l1);
		r1=codeGen(t->left);
		fprintf(fp,"JZ R%d l%d\n",r1,l2);
		r1=codeGen(t->right);
		fprintf(fp,"JMP l%d\n",l1);
		fprintf(fp,"l%d:\n",l2);
		freeReg();	
	}	
}

/*int evaluate(struct tnode *t){
	struct gnode *temp;
	if(t->nodetype == NUM)
	return t->value;
	else if(t->nodetype == READ){
		temp=glookup(t->left->name);
		if(temp->size == 1)
			scanf("%d",temp->binding);
		else
		{
			t->left->value=evaluate(t->left->left);
			scanf("%d",&temp->binding[t->left->value]);
		}	
		return 1;
	}
	else if(t->nodetype == WRITE){
		printf("%d\n",evaluate(t->left));
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
	}
	else if(t->nodetype == ID){
	if(glookup(t->name) == NULL){
		printf("Not in entry\n");
		exit(1);
	}
		temp=glookup(t->name);
		return *(temp->binding);
	}
	else if(t->nodetype == ID_ARRAY){
		if(glookup(t->name) == NULL){
			printf("Not in entry\n");
			exit(1);
		}
		temp=glookup(t->name);
		t->value=evaluate(t->left);
		return temp->binding[t->value];	
	}
	else if(t->nodetype == '+'){
		return (evaluate(t->left) + evaluate(t->right));
	}	
	else if(t->nodetype == '-'){
		return (evaluate(t->left) - evaluate(t->right));
	}
	else if(t->nodetype == '*'){
		return (evaluate(t->left) * evaluate(t->right));
	}
	else if(t->nodetype == '/'){
		return (evaluate(t->left) / evaluate(t->right));
	}
	else if(t->nodetype == '%'){
		return (evaluate(t->left) % evaluate(t->right));
	}
	else if(t->nodetype == GT){
		return (evaluate(t->left) > evaluate(t->right));
	}
	else if(t->nodetype == LT){
		return (evaluate(t->left) < evaluate(t->right));
	}
	else if(t->nodetype == LE){
		return (evaluate(t->left) <= evaluate(t->right));
	}
	else if(t->nodetype == GE){
		return (evaluate(t->left) >= evaluate(t->right));
	}
	else if(t->nodetype == NE){
		return (evaluate(t->left) != evaluate(t->right));
	}
	else if(t->nodetype == TRUE ){
			return 1;
	}
	else if(t->nodetype == FALSE ){
			return 0;
	}
	else if(t->nodetype == EQUAL){
		return (evaluate(t->left) == evaluate(t->right));
	}
	else if(t->nodetype == AND ){
			return (evaluate(t->left) && evaluate(t->right));
	}
	else if(t->nodetype == OR ){
			return (evaluate(t->left) || evaluate(t->right));
	}
	else if(t->nodetype == NOT ){
			return (~evaluate(t->left));
	}
	else if(t->nodetype == 3){
		evaluate(t->left);
		evaluate(t->right);
		return 1;
	}
	else if(t->nodetype == '='){	
	if(glookup(t->left->name) == NULL){
		printf("Not in entry\n");
		exit(1);
		}
		temp=glookup(t->left->name);
		if(temp->size == 1)
			*(temp->binding)=evaluate(t->right);
		else
		{
			t->left->value=evaluate(t->left->left);
			temp->binding[t->left->value]=evaluate(t->right);
		}
	}
}*/

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
	fp=fopen("out7.txt","w+");
	yyparse();
	fclose(yyin);
	return 1;
}
