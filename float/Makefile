all:
	nasm -g -f elf64 -o dot_product.o dot_product.asm
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc dot_product.o -o dot_product

clean:
	rm dot_product dot_product.o
