yacc -d sag61.y
lex sag61.l
gcc y.tab.c
./a.out t1.txt