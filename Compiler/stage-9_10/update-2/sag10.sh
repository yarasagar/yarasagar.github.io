yacc -d sag10.y
lex sag10.l
gcc y.tab.c
./a.out test_swap.sil
cp out.txt ../sim-2/out.txt
../sim-2/./sim ../sim-2/out.txt