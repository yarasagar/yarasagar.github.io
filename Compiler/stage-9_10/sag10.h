int line=1;

struct argnode{
	char *name;
	int type;
	struct argnode *next;
};
void arginstall(char *name,int type);

struct gnode{
	char *name;
	int type;
	int size;
	int binding;
	struct argnode *arglist;
	struct gnode *next;
};
struct gnode *glookup(char *name);
void ginstall(char *name,int type,int size,struct argnode *arglist);

struct lnode{
	char *name;
	int type;
	int binding;
	int refertype;
	struct lnode *next;
};
struct lnode *llookup(char *name);
void linstall(char *name,int type,int refertype,int ar);

struct tnode{
	int type;
	int nodetype;
	char *name;
	int value;
	struct tnode *ArgList;
	struct tnode *left;
	struct tnode *middle;
	struct tnode *right;
//	struct gnode *gentry;
//	struct lnode *lentry;
};
//argcheck(struct argnode *arglist);
