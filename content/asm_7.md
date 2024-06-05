
It is seventh part of Say hello to x86_64 Assembly and here we will look on how we can use C together with assembler.

Actually we have 3 ways to use it together:

* Call assembly routines from C code
* Call c routines from assembly code
* Use inline assembly in C code

Let's write 3 simple Hello world programs which shows us how to use assembly and C together.

## Call assembly from C

First of all let's write simple C program like this:

```C
#include <string.h>

int main() {
	char* str = "Hello World\n";
	int len = strlen(str);
	printHelloWorld(str, len);
	return 0;
}
```

Here we can see C code which defines two variables: our Hello world string which we will write to stdout and length of this string. Next we call printHelloWorld assembly function with this 2 variables as parameters. As we use x86_64 Linux, we must know x86_64 linux calling convetions, so we will know how to write printHelloWorld function, how to get incoming parameters and etc... When we call function first six parameters passes through rdi, rsi, rdx, rcx, r8 and r9 general purpose registers, all another through the stack. So we can get first and second parameter from rdi and rsi registers and call write syscall and than return from function with ret instruction:

```assembly
global printHelloWorld

section .text
printHelloWorld:
		;; 1 arg
		mov r10, rdi
		;; 2 arg
		mov r11, rsi
		;; call write syscall
		mov rax, 1
		mov rdi, 1
		mov rsi, r10
		mov rdx, r11
		syscall
		ret
```

Now we can build it with:

```
build:
	nasm -f elf64 -o casm.o casm.asm
	gcc casm.o casm.c -o casm
```

## Inline assembly

The following method is to write assembly code directly in C code. There is special syntax for this. It has general view:

```
asm [volatile] ("assembly code" : output operand : input operand : clobbers);
```

As we can read in gcc documentation volatile keyword means:

```
The typical use of Extended asm statements is to manipulate input values to produce output values. However, your asm statements may also produce side effects. If so, you may need to use the volatile qualifier to disable certain optimizations
```

Each operand is described by constraint string followed by C expression in parentheses. There are a number of constraints:

* `r` - Kept variable value in general purpose register
* `g` - Any register, memory or immediate integer operand is allowed, except for registers that are not general registers.
* `f` - Floating point register
* `m` - A memory operand is allowed, with any kind of address that the machine supports in general.
* and etc...

So our hello world will be:

```C
#include <string.h>

int main() {
	char* str = "Hello World\n";
	long len = strlen(str);
	int ret = 0;

	__asm__("movq $1, %%rax \n\t"
		"movq $1, %%rdi \n\t"
		"movq %1, %%rsi \n\t"
		"movl %2, %%edx \n\t"
		"syscall"
		: "=g"(ret)
		: "g"(str), "g" (len));

	return 0;
}
```

Here we can see the same 2 variables as in previous example and inline assembly definition. First of all we put 1 to rax and rdi registers (write system call number, and stdout) as we did it in our plain assembly hello world. Next we do similar operation with rsi and rdi registers but first operands starts with % symbol instead $. It means str is the output operand referred by %1 and len second output operand referred by %2, so we put values of str and len to rsi and rdi with %n notation, where n is number of output operand. Also there is %% prefixed to the register name.

```
    This helps GCC to distinguish between the operands and registers. operands have a single % as prefix
```

We can build it with:

```
build:
	gcc casm.c -o casm
```

## Call C from assembly

And the last method is to call C function from assembly code. For example we have following simple C code with one function which just prints Hello world:

```C
#include <stdio.h>

extern int print();

int print() {
	printf("Hello World\n");
	return 0;
}
```

Now we can define this function as extern in our assembly code and call it with call instruction as we do it much times in previous posts:

```asssembly
global _start

extern print

section .text

_start:
		call print

		mov rax, 60
		mov rdi, 0
		syscall
```

Build it with:

```
build:
	gcc  -c casm.c -o c.o
	nasm -f elf64 casm.asm -o casm.o
	ld   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc casm.o c.o -o casm
```

and now we can run our third hello world.
