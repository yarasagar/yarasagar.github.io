typedef struct tnode{
		int flag;
		int val;
		char op;
		struct tnode *left;
		struct tnode *right;
}node;

#define YYSTYPE node *
