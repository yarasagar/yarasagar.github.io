yacc -d sag8.y
lex sag8.l
gcc y.tab.c
./a.out t2.txt