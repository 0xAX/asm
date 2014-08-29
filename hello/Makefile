
# check nasm version, must be more than 2.0
all:
	nasm -f elf64 -o hello.o hello.asm
	ld -o hello hello.o

clean:
	rm hello hello.o
