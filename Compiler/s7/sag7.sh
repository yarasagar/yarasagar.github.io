yacc -d sag7.y
lex sag7.l
gcc y.tab.c
./a.out t2.txt