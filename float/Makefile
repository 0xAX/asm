build:
	gcc  -g -c circle_fpu_87c.c -o c.o
	nasm -f elf64 circle_fpu_87.asm -o circle_fpu_87.o
	ld   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc circle_fpu_87.o  c.o -o testFloat1

clean:
	rm -rf *.o
	rm -rf testFloat1
