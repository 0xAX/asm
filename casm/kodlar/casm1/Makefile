buildAsmc:
	gcc  -c casm.c -o c.o
	nasm -f elf64 casm.asm -o casm.o
	ld   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc casm.o c.o -o casm

clean:
	rm -rf *.o
	rm -rf casm

