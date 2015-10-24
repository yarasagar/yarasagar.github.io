struct gnode{
	char *name;
	int type;
	int size;
	int *binding;
	struct gnode *next;
};

struct gnode *glookup(char *name);
void ginstall(char *name,int type,int size);
int line=0;

struct tnode{
	int type;
	int nodetype;
	char *name;
	int value;
	struct tnode *left;
	struct tnode *middle;
	struct tnode *right;
	struct gnode *gentry;
};
