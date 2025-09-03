all:
	nasm -f elf64 -o casm.o casm.asm
	gcc casm.o casm.c -o casm 

clean:
	rm -rf *.o
	rm -rf casm
