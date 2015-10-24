typedef struct tnode{
		int flag;
		int val;
            	char op;
		struct tnode *right;
		struct tnode *left;
}node;

#define YYSTYPE node *
