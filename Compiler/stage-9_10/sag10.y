%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lex.yy.c"
	#define ID_ARRAY 100
	int vartype,count=0,count2=1,count3=-3;
	FILE *fp;
	int reg=-1,lab=-1;
	struct tnode *makenode(int ,int ,char *,int ,struct tnode *,struct tnode *,struct tnode *);
	void typechecking(struct tnode *,struct tnode *,struct tnode *,struct tnode *);
	void functionGen(struct tnode *);
	void compil();
	struct gnode *head=NULL;
	struct lnode *head2=NULL;
	struct argnode *head3=NULL;
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
%token <val> ELSE
%token <val> ENDELSE
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
%token <val> BEG
%token <val> END
%token <val> RETURN
%token <variable> MAIN
%token <val> FUNCTION
%token <val> GAD
%token <val> LAD

%type <ptr> body
%type <ptr> exprlist
%type <ptr> rstmt
%type <ptr> slist
%type <ptr> stmt
%type <ptr> expr
%type <ptr> var
%type <ptr> fdecl
%type <ptr> maindef

%left '%'
%left '+' '-' ',' ';' 
%left '*' '/'
%nonassoc GT GE LT LE EQUAL NE AND OR NOT

%%
prog:	gdef fdef maindef	{compil();exit(1);}
	;
gdef:	DECL glist ENDDECL 
	;
glist:	gdecl glist 
	| 
	;
gdecl:	Type gidlist ';'
	;
Type:	INTEGER		{vartype=INTEGER;}
	| BOOLEAN 	{vartype=BOOLEAN;}
	;			
gidlist:	gidlist ',' gid
	| gid
	;
gid:	ID	{ginstall($1,vartype,1,NULL);}
	| ID '(' arglist ')'	{ginstall($1,vartype,0,head3);head3=NULL;}	
	| ID '[' NUM ']'	{ginstall($1,vartype,$3,NULL);}
	;
arglist : arglist ';' arg 
	| arg
	| 
	;
arg:	Type argidlist
	;				
argidlist:	argidlist ',' ID	{arginstall($3,vartype);}
	| argidlist ',' '&' ID		{arginstall($4,vartype);}
	| ID	{arginstall($1,vartype);}
	| '&' ID	{arginstall($2,vartype);}
	;
fdef:	fdef fdecl
	|
	;
fdecl:	Type ID '(' arglist2 ')' '{' ldef body '}'	{$$=makenode(vartype,FUNCTION,$2,-1,$8,NULL,NULL);functionGen($$);}//typechecking($$,$$->left,$$->middle,$$->right);}
	;		
arglist2:	arglist2 ';' arg2	
	| arg2
	|	
	;
arg2:	Type argidlist2
	;		
argidlist2:	argidlist2 ',' ID	{linstall($3,vartype,0,1);}	//0 for id and 1 for &id //1 for arg and 0 for local
	| argidlist2 ',' '&' ID		{linstall($4,vartype,1,1);}
	| ID	{linstall($1,vartype,0,1);}
	| '&' ID	{linstall($2,vartype,1,1);}
	;
ldef:	DECL llist ENDDECL 
	;
llist:	llist ldecl
	|
	;
ldecl:	Type lidlist ';'
	;
lidlist:	lidlist ',' lid
	| lid
	;
lid:	ID	{linstall($1,vartype,0,0);}
	;
	
	
	
	
	
maindef:	INTEGER MAIN '(' ')' '{' ldef body '}'	{$$=makenode(INTEGER,FUNCTION,"main",-1,$7,NULL,NULL);functionGen($$);}//typechecking($$,$$->left,$$->middle,$$->right);}
	;
body:	BEG slist rstmt END			{$$=makenode(VOID,FUNCTION,NULL,-1,$2,NULL,$3);}
	;
slist:	slist stmt	{$$=makenode(VOID,3,NULL,-1,$1,NULL,$2);}
	| stmt		{$$=$1;}
	;
stmt:	var '=' expr ';'		{$$=makenode(VOID,'=',NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| READ '(' var ')' ';'	{$$=makenode(VOID,READ,NULL,-1,$3,NULL,NULL);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| WRITE '(' expr ')' ';'	{$$=makenode(VOID,WRITE,NULL,-1,$3,NULL,NULL);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| IF '(' expr ')' THEN slist ENDIF ';'	{$$=makenode(VOID,IF,NULL,-1,$3,NULL,$6);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| IF '(' expr ')' THEN slist ELSE slist ENDELSE ';'	{$$=makenode(VOID,ELSE,NULL,-1,$3,$8,$6);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| WHILE '(' expr ')' DO slist ENDWHILE ';'	{$$=makenode(VOID,WHILE,NULL,-1,$3,NULL,$6);}// typechecking($$,$$->left,$$->middle,$$->right);}
	;
expr:	expr '+' expr	{$$=makenode(INTEGER,'+',NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr '-' expr	{$$=makenode(INTEGER,'-',NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr '/' expr	{$$=makenode(INTEGER,'/',NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr '*' expr	{$$=makenode(INTEGER,'*',NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr '%' expr	{$$=makenode(INTEGER,'%',NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| ID '(' exprlist ')'	{struct gnode *k=glookup($1);$$=makenode(k->type,FUNCTION,$1,-1,NULL,NULL,NULL);
										$$->ArgList=$3;	}
									//typechecking($$,$$->left,$$->middle,$$->right);}
	| '(' expr ')'	{$$=$2;}
	| expr GT expr		{$$=makenode(BOOLEAN,GT,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr LT expr		{$$=makenode(BOOLEAN,LT,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr EQUAL expr	{$$=makenode(BOOLEAN,EQUAL,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr GE expr		{$$=makenode(BOOLEAN,GE,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr LE expr		{$$=makenode(BOOLEAN,LE,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr NE expr		{$$=makenode(BOOLEAN,NE,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr AND expr		{$$=makenode(BOOLEAN,AND,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| expr OR expr		{$$=makenode(BOOLEAN,OR,NULL,-1,$1,NULL,$3);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| NOT expr		{$$=makenode(BOOLEAN,NOT,NULL,-1,$2,NULL,NULL);}// typechecking($$,$$->left,$$->middle,$$->right);}
	| TRUE			{$$=makenode(BOOLEAN,TRUE,NULL,-1,NULL,NULL,NULL);}
	| FALSE			{$$=makenode(BOOLEAN,FALSE,NULL,-1,NULL,NULL,NULL);}
	| NUM	{$$=makenode(INTEGER,NUM,NULL,$1,NULL,NULL,NULL);}
	| var 	{$$=$1;}
	;
var:	ID 			{struct lnode *t=llookup($1);if(t == NULL){
									struct gnode *z=glookup($1);
									if(z==NULL){yyerror();}
									
									$$=makenode(z->type,ID,$1,-1,NULL,NULL,NULL);
									}
								else{
									$$=makenode(t->type,ID,$1,-1,NULL,NULL,NULL);
								}
								//typechecking($$,$$->left,$$->middle,$$->right);
								}	
	| ID '[' expr ']'	{struct gnode *temp=glookup($1);$$=makenode(temp->type,ID_ARRAY,$1,-1,$3,NULL,NULL);}
								//typechecking($$,$$->left,$$->middle,$$->right);}
	;
exprlist:	exprlist ',' expr	{$$=makenode(VOID,6,NULL,-1,$1,NULL,$3);}
	| expr	{$$=$1;}
	| exprlist ',' '&' ID	{struct tnode *t;
				struct lnode *d=llookup($4);
				if(d==NULL){
					struct gnode *z=glookup($4);
					t=makenode(VOID,GAD,NULL,z->binding,NULL,NULL,NULL);	
				}else{
					t=makenode(VOID,LAD,NULL,d->binding,NULL,NULL,NULL);		
				}	
					$$=makenode(VOID,6,NULL,-1,$1,NULL,t);
				}
	| exprlist ',' '&' ID '[' expr ']'	{struct gnode *z=glookup($4);
						struct tnode *t;
						t=makenode(VOID,GAD,NULL,z->binding,$6,NULL,NULL);	
						$$=makenode(VOID,6,NULL,-1,$1,NULL,t);		
						}	
	| '&' ID		{	struct lnode *d=llookup($2);
					if(d==NULL){
						struct gnode *z=glookup($2);		
						$$=makenode(VOID,GAD,NULL,z->binding,NULL,NULL,NULL);	
					}else{
						$$=makenode(VOID,LAD,NULL,d->binding,NULL,NULL,NULL);		
					}	
				}
	| '&' ID '[' expr ']'	{struct gnode *z=glookup($2);$$=makenode(VOID,GAD,NULL,z->binding,$4,NULL,NULL);}
	|	{$$=NULL;}
	;	
rstmt:	RETURN expr ';'	{$$=$2;}
	;	
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
struct gnode *glookup(char *nam){
	struct gnode *tem=head;
	while(tem!=NULL){
		//printf("%s\n",tem->name);
		if(strcmp(tem->name,nam)==0)
		break;
		else
		tem=tem->next;
	}
	if(tem==NULL){
		//printf("variable not found %s and %d\n",nam,line);
		return NULL;
	}
	return tem;
}
struct lnode *llookup(char *nam){
	struct lnode *tem=head2;
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
	printf("%d Error\n",line);
	return 1;
}
void ginstall(char *nam,int typ,int siz,struct argnode *arglis){
	struct gnode *tem=head;
/*	if(glookup(nam) != NULL){
		printf("Already exist");
		exit(1);
		}
*/	if(tem==NULL){
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
	tem->arglist=arglis;
	tem->next=NULL;
}
void linstall(char *nam,int typ,int refertyp,int ar){
	struct lnode *tem=head2;
/*	if(llookup(nam) != NULL){
		printf("Already exist");
		exit(1);
		}
*/	if(tem==NULL){
		head2=malloc(sizeof(struct lnode));
		tem=head2;
	}
	else{
		while(tem->next!=NULL){
			tem=tem->next;
		}
		tem->next=malloc(sizeof(struct lnode));
		tem=tem->next;
	}
	tem->name=nam;
	tem->type=typ;	
	if(ar==1)
	{
		tem->binding=count3;
		count3=count3-1;
	}
	else
	{
		tem->binding=count2;
		count2=count2+1;
	}	
	tem->refertype=refertyp;
	tem->next=NULL;
}
void arginstall(char *nam,int typ){
	struct argnode *tem=head3;
	if(tem==NULL){
		head3=malloc(sizeof(struct argnode));
		tem=head3;
	}
	else{
		while(tem->next!=NULL){
			tem=tem->next;
		}
		tem->next=malloc(sizeof(struct argnode));
		tem=tem->next;
	}
	tem->name=nam;
	tem->type=typ;
	tem->next=NULL;
}

void functionGen(struct tnode *t){
	int r1,r2,r3;
	fprintf(fp,"%s: \n",t->name);
	fprintf(fp,"PUSH BP\n");
	fprintf(fp,"MOV BP,SP\n");
	r1=getReg();
	r2=getReg();	
	fprintf(fp,"MOV R%d,%d\n",r1,count2-1);
	fprintf(fp,"MOV R%d,SP\n",r2);
	fprintf(fp,"ADD R%d,R%d\n",r1,r2);
	fprintf(fp,"MOV SP,R%d\n",r1);
	freeReg();
	freeReg();
	r1=codeGen(t->left->left);
	r1=codeGen(t->left->right);
	r2=getReg();
	r3=getReg();
	fprintf(fp,"MOV R%d,BP\n",r2);
	fprintf(fp,"MOV R%d,2\n",r3);
	fprintf(fp,"SUB R%d,R%d\n",r2,r3);
	fprintf(fp,"MOV [R%d],R%d\n",r2,r1);
	freeReg();
	freeReg();
	freeReg();
	r1=getReg();
	r2=getReg();
	fprintf(fp,"MOV R%d,%d\n",r1,count2-1);
	fprintf(fp,"MOV R%d,SP\n",r2);
	fprintf(fp,"SUB R%d,R%d\n",r2,r1);
	fprintf(fp,"MOV SP,R%d\n",r2);
	freeReg();
	freeReg();
	fprintf(fp,"POP BP\n");
	fprintf(fp,"RET\n");
	head2=NULL;
	count2=1;
	count3=-3;
}

void compil(){
	int r1,r2;
	fprintf(fp,"START\n");
	fprintf(fp,"MOV BP,0\n");
	if(count!=0){
		fprintf(fp,"MOV SP,%d\n",count-1);
	}
	else{
		fprintf(fp,"MOV SP,%d\n",count);
	}
	r1=getReg();
	fprintf(fp,"MOV R%d,0\n",r1);
	fprintf(fp,"PUSH R%d\n",r1);
	freeReg();
	fprintf(fp,"CALL main\n");
	fprintf(fp,"HALT\n");
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
	int loc,r1,r2;
	struct lnode *l=llookup(te->name);
	struct gnode *tem=glookup(te->name);
	if(l != NULL){
		if(l->refertype == 1){
			loc=l->binding;
			r1=getReg();
			r2=getReg();
			fprintf(fp,"MOV R%d,BP\n",r2);
			fprintf(fp,"MOV R%d,%d\n",r1,loc);
			fprintf(fp,"ADD R%d,R%d\n",r2,r1);
			fprintf(fp,"MOV R%d,[R%d]\n",r1,r2);
			freeReg();
			return r1;	//
		}
		else{
			loc=l->binding;
			r1=getReg();
			r2=getReg();
			fprintf(fp,"MOV R%d,BP\n",r1);
			fprintf(fp,"MOV R%d,%d\n",r2,loc);
			fprintf(fp,"ADD R%d,R%d\n",r1,r2);
			freeReg();
			return r1;
		}
	}
	else if(tem != NULL){
		loc=tem->binding;
		r1=getReg();	
		fprintf(fp,"MOV R%d,%d\n",r1,loc);
		return r1;
	}
}

void argpop(struct tnode *tem){
	int r1;
	if(tem != NULL){
		if(tem->nodetype == 6){
			argpop(tem->left);
			argpop(tem->right);
		}
		else{
			r1=getReg();
			fprintf(fp,"POP R%d\n",r1);
			freeReg();
		}
	}
}

void argpush(struct tnode *tem){
	int r1,r2;
	if(tem != NULL){
		if(tem->nodetype == 6){
			argpush(tem->left);
			argpush(tem->right);
		}
		else{
			if(tem->nodetype == GAD){
				if(tem->left == NULL){
					r1=getReg();
					fprintf(fp,"MOV R%d,%d\n",r1,tem->value);
					fprintf(fp,"PUSH R%d\n",r1);
					freeReg();
				}
				else{	
					r1=getReg();
					r2=codeGen(tem->left);
					fprintf(fp,"MOV R%d,%d\n",r1,tem->value);
					fprintf(fp,"ADD R%d,R%d\n",r1,r2);
					fprintf(fp,"PUSH R%d\n",r1);
					freeReg();
					freeReg();
				}
			}
			else if(tem->nodetype == LAD){
				r1=getReg();
				r2=getReg();
				fprintf(fp,"MOV R%d,BP\n",r2);
				fprintf(fp,"MOV R%d,%d\n",r1,tem->value);
				fprintf(fp,"ADD R%d,R%d\n",r1,r2);
				freeReg();
				fprintf(fp,"PUSH R%d\n",r1);
				freeReg();
			}
			else{
				r1=codeGen(tem);
				fprintf(fp,"PUSH R%d\n",r1);
				freeReg();
			}
		}
	}
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
			r2=getReg();
			r3=getBinding(t->left);
			r4=getBinding(t->left->left);	
			fprintf(fp,"IN R%d\n",r1);
			fprintf(fp,"MOV R%d,R%d\n",r2,r4);
			fprintf(fp,"ADD R%d,R%d\n",r2,r3);	
			fprintf(fp,"MOV [R%d],R%d\n",r2,r1);
			freeReg();
			freeReg();
			freeReg();
			freeReg();
		}
		return r1;
	}
	else if(t->nodetype == WRITE){
		r1=codeGen(t->left);
		fprintf(fp,"OUT R%d\n",r1);
		return r1;
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
			r2=getReg();
			r3=getBinding(t->left);
			r4=getBinding(t->left->left);
			fprintf(fp,"MOV R%d,R%d\n",r2,r4);
			fprintf(fp,"ADD R%d,R%d\n",r2,r3);	
			fprintf(fp,"MOV [R%d],R%d\n",r2,r1);
			freeReg();
			freeReg();
			freeReg();
			freeReg();
		}
		return r1;
	}
	else if(t->nodetype == ID_ARRAY){
		r1=getReg();
		r2=getBinding(t)+t->left->value;	//
		fprintf(fp,"MOV R%d [R%d]\n",r1,r2);
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
	else if(t->nodetype == FUNCTION){
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
		freeReg(r3);
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
	else if(t->nodetype == 3){
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
	else if(t->nodetype == ELSE){
		l1=getLabel();
		l2=getLabel();
		r1=codeGen(t->left);
		fprintf(fp,"JZ R%d l%d\n",r1,l1);
		freeReg();
		r1=codeGen(t->right);
		fprintf(fp,"JMP l%d\n",l2);
		fprintf(fp,"l%d:\n",l1);
		r2=codeGen(t->middle);
		fprintf(fp,"l%d:\n",l2);
	}
	else if(t->nodetype == WHILE){
		l1=getLabel();
		l2=getLabel();
		fprintf(fp,"l%d:\n",l1);
		r1=codeGen(t->left);
		fprintf(fp,"JZ R%d l%d\n",r1,l2);
		freeReg();	
		r1=codeGen(t->right);
		fprintf(fp,"JMP l%d\n",l1);
		fprintf(fp,"l%d:\n",l2);
	}	
}

/*void typechecking(struct tnode *tree,struct tnode *le,struct tnode *midd,struct tnode *rig){
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
	else if(tree->nodetype == ID){
		struct gnode *g=glookup(tree->name);
		if(g->size != 0){
			printf("Id may be array");
			exit(1);
		}
	}
	else if(tree->nodetype == ID_ARRAY){
		struct gnode *g=glookup(tree->name);
		if(g->size > -1 && g->size < tree->value)
		;
		else{
			printf("Error in idarray");
			exit(1);
		}
	}
	else if(tree->nodetype == FUNCTION){
		if(strcmp(tree->name,"main") != 0){
			struct gnode *t=glookup(tree->name);
			if(t == NULL){
				printf("Error in function");
				exit(1);
			}
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
}*/

int main(int argc,char *argv[]){
	yyin=fopen(argv[1],"r");
	fp=fopen("out.txt","w+");
	yyparse();
	fclose(yyin);
	return 1;
}
