
# check nasm version, must be more than 2.0
all:
	nasm -f elf64 -o hello.o hello.asm
	ld -o hello hello.o

	gcc -S helloc.c
	gcc helloc.c -o helloc

clean:
	rm hello hello.o
	rm helloc helloc.s
