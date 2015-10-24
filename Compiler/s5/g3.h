typedef struct tnode{
int flag;
int val;
char op;
char *s;
struct tnode *left;
struct tnode *right;
}node;

#define YYSTYPE node *
