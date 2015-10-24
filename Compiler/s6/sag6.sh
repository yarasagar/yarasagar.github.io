yacc -d sag6.y
lex sag6.l
gcc y.tab.c
./a.out t.txt