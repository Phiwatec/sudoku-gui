help:
	@echo "To assemble for ARM do 'make arm'"
	@echo "To assemble for x86_64 do 'make x86'"
	@echo "To compile for any other arch do 'make c'"
	@echo "Binary will be named 'sudoku'"

arm: main.o
	ld main.o -o sudoku
main.o: main.s
	as main.s -o main.o

x86: main.obj
	ld main.obj -o sudoku
main.obj: main.asm
	as main.asm -o main.obj

c: sudoku.c
	gcc -o sudoku sudoku.c
