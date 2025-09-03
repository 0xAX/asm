# Interaction of assembly and high-level programming languages

In all the previous chapters, we were writing our programs almost entirely using pure assembly programming language. While this is a great way to learn how some aspects of a process works, it is not how you’ll meet assembly in real world. Of course, nothing prevents you from writing whole applications in assembly, but in practice it’s rare. Most of the time, you will see an assembly code inside programs written in higher-level languages such as C or C++. In this chapter, we will explore how to combine assembly with C code on Linux x86_64.

There are three main ways you’ll see them used together:

- Call C routines from assembly code
- Call assembly routines from C code
- Use inline assembly in C code

During this chapter we will take a look at the examples which show the usage of these method.

## Call C routines from assembly code

We will start our journey from the example which shows how we can call a C [function](https://en.wikipedia.org/wiki/Function_(computer_programming)) from an assembly code. This already should be familiar for us, as we have seen examples of using C functions in the [previous chapter](./asm-6.md).

Let's remember the [hello world](./asm-1.md) example from the very first chapter:

```assembly
;; Definition of the `data` section
section .data
    ;; String `msg` variable with the value `hello world!`
    msg db "hello, world!"

;; Definition of the text section
section .text
    ;; Reference to the entry point of our program
    global _start

;; Entry point
_start:
    ;; Specify the number of the system call (1 is `sys_write`).
    mov rax, 1
    ;; Set the first argument of `sys_write` to 1 (`stdout`).
    mov rdi, 1
    ;; Set the second argument of `sys_write` to the reference of the `msg` variable.
    mov rsi, msg
    ;; Set the third argument of `sys_write` to the length of the `msg` variable's value (13 bytes).
    mov rdx, 13
    ;; Call the `sys_write` system call.
    syscall

    ;; Specify the number of the system call (60 is `sys_exit`).
    mov rax, 60
    ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
    mov rdi, 0
    ;; Call the `sys_exit` system call.
    syscall
```

Basically, this example consists just of the invocation of the two [system calls](https://en.wikipedia.org/wiki/System_call):

1. `sys_write` - used to write the given string to the standard output.
2. `sys_exit` - used to terminate the program and return control back to the operating system.

Instead of using these system calls, we can use C functions:

- [write](https://www.man7.org/linux/man-pages/man3/write.3p.html)
- [exit](https://man7.org/linux/man-pages/man3/exit.3.html)

Let's take a look at the implementation:

```assembly
;; Definition of the `data` section
section .data
    ;; String `msg` variable with the value `hello world!`
    msg db "hello, world!"

    ;; Reference to the C stdlib functions that we will use
    extern write, exit

;; Definition of the text section
section .text
    ;; Reference to the entry point of our program
    global _start

;; Entry point
_start:
    ;; Set the first argument of `write` function to 1 (`stdout`).
    mov rdi, 1
    ;; Set the second argument of `write` function to the reference of the `msg` variable.
    mov rsi, msg
    ;; Set the third argument to the length of the `msg` variable's value (13 bytes).
    mov rdx, 13
    ;; Call the `write` function.
    call write

    ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
    mov rdi, 0
    ;; Call the `exit` function
    call exit
```

The logic of this program should look pretty similar to the example above. The main difference is that we use the `call` instruction with the function name instead of the `syscall` instruction. In addition, you may note that since we are using the functions from the standard library, we do not need to specify the number of the system call anymore. The general purpose registers that we use to pass function parameters also look pretty similar, but there is the difference as well. The following registers are used to pass parameters to the non system call functions:

- `rdi` - used to pass the first argument to a function.
- `rsi` - used to pass the second argument to a function.
- `rdx` - used to pass the third argument to a function.
- `rcx` - used to pass the fourth argument to a function.
- `r8` - used to pass the fifth argument to a function.
- `r9` - used to pass the sixth argument to a function.

If there is more parameters than six, the rest of it will be passed on the [stack](./asm.2).

You can build the code above using these instructions and make sure that it works as expected:

```bash
nasm -f elf64 casm.asm -o casm.o
ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc casm.o -o casm
```

Then, let's run it:

```
./casm
hello, world!
```

## Call assembly routines from C

After we have seen how to call C functions from assembly, it’s time to flip the perspective. Now let's try to figure out how assembly code can be exposed as a function and then called from a higher-level language. This is quite important to understand as I mentioned in the beginning of this chapter - in practice assembly is rarely a standalone program. Much more often its pieces live inside a larger project written on a higher level programming language. By writing small assembly routines and calling them like normal functions, it let us achieve performance optimizations beyond what the compiler might provide to us or use the capabilities that are simply not accessible from a higher-level language.

There are two main ways to use assembly code from within C:

1. Calling an assembly function directly
2. Embedding inline assembly inside C source code

In this section, we will focus on the first approach. Later, in the final part of this chapter, we’ll return to the second and explore how inline assembly works.

Let’s build a simple program in C that calculates the length of the first command-line argument and prints it. The actual string-length routine will be implemented in assembly:

```C
#include <stdio.h>
#include <stdlib.h>

extern int my_strlen(const char *str);

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Error: this program must have 1 command line argument\n");
        return EXIT_FAILURE;
    }

    printf("The argument length is - %d\n", my_strlen(argv[1]));

    return 0;
}
```

This is straightforward C code which I think not needed to be explained in details. It checks that exactly one command-line argument was passed, then calls the `my_strlen` function to determine its length. The result is printed to standard output. As I said - pretty straightforward. The single part which interests us is the implementation of the `my_strlen` function. This function is written in assembly, but not in C.

Let's take a look at the implementation of this function:

```assembly
;; Definition of the text section
section .text
        ;; Reference to the entry point of our program
        global my_strlen

;; Function that returns the length of the string passed via the first argument
my_strlen:
        ;; Reset the register value to zero. It will be returned from the
        ;; function with the result.
        xor rax, rax
.loop:
        ;; Compare the first element in the given string with the `NUL` terminator (end of the string).
        cmp byte [rdi + rax], 0
        ;; If we reached the `NUL` terminator exit from the function.
        je .done
        ;; Increase the counter which stores the length of the string.
        inc rax
        ;; Repeat the operations above while we didn't reach the end of the string.
        jmp .loop
.done:
        ;; Exit from the function and return the result in the `rax` register.
        ret
```

The way function's parameters are passed to our assembly function follows the same calling convention which we have seen in the section above. The first argument, which our case is a pointer to the string, passed in the `rdi` register. At the start of the function we clear the value of the `rax` register, since this will serve as our counter. Each time we encounter a character in the string, the loop increments `rax` using it as an accumulator for the string’s length. The loop continues character by character until it reaches the `NUL` terminator, which signals the end of the string. At that point, the value stored in rax is returned to the caller as the final result.

We can build our program using the following commands:

```bash
nasm -f elf64 -o casm.o casm.asm
gcc casm.o casm.c -o casm
```

And run it:

```
./casm hello
The argument length is - 5
```

## Use inline assembly in C code

In the section above, we already have mentioned that calling an assembly function from a C code is not a single way to use assembly code from within a C program. The second method is to use `inline assembly`. This method allows us to write an assembly code directly in our C code. This can be useful for performance-critical operations, or when you need to access processor instructions that the compiler does not expose through standard C.

In [GCC](https://gcc.gnu.org/) (and in other compilers as well), inline assembly uses a special syntax. In its general form it looks like this:

```C
asm [volatile] ("assembly code"
                : output operands
                : input operands
                : clobbers);
```

The `asm` keyword introduces the inline assembly block. Adding the `volatile` qualifier tells the compiler not to optimize away or reorder this code, which is important if the code has side effects that the compiler cannot see. As the [GCC documentation](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html) explains:

> The typical use of Extended asm statements is to manipulate input values to produce output values. However, your asm statements may also produce side effects. If so, you may need to use the volatile qualifier to disable certain optimizations.

After the definition of the assembly code, we can specify input and output operands which describe how C variables should be mapped to registers or memory. Each operand consists of a constraint string followed by the C expression in parentheses. The constraint tells the compiler what kind of location can hold the operand, and ensures that values are moved in and out properly.

For example:

- `r` - tells compiler to use a [general-purpose register](./asm_2.md).
- `g` - tells compiler to use any register, memory, or immediate integer operand.
- `f` - tells compiler to use a [floating point register](./asm_6.md).
- `m` - forces compiler to use a memory location.

All the supported constraint strings you can find in the [official documentation](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html#Output-Operands).

Let's try to rewrite our `hello world` program using the inline assembly.

```C
#include <stdio.h>
#include <string.h>

int main() {
	char* str = "Hello World\n";
	long len = strlen(str);
	int ret = 0;

	__asm__("movq $1, %%rax \n\t" // rax = 1 - Specify the number of the system call (1 is `sys_write`).
		"movq $1, %%rdi \n\t"     // rdi = 1 - Set the first argument of `sys_write` to 1 (`stdout`).
		"movq %1, %%rsi \n\t"     // rsi = str - Set the second argument of `sys_write` to the reference of the `str` variable.
		"movq %2, %%rdx \n\t"     // rdx = len(str) - Set the third argument of `sys_write` to the length of the `str` variable's value.
		"syscall"                 // Call the `sys_write` system call.
		: "=g"(ret)               // Return the result in the `ret` variable.
		: "g"(str), "g" (len));   // Put `str` and `len` variables in any general operand (memory, register or immediate if possible)

        printf("Bytes written: %d\n", ret);
	return 0;
}
```

> [!NOTE]
> In the example above we have used [GNU as](https://sourceware.org/binutils/docs/as.html) assembly which has a slightly different syntax from the [NASM](https://nasm.us/) assembly. The main differences is that order of operands for the `movq` instruction is changed. We move the value of the left operand to right.

We can build the code above using these instructions:

```bash
gcc casm.c -o casm
```

After building we can run it:

```bash
./casm
Hello World
Bytes written: 12
```

## Conclusion

This was the final chapter of our journey into assembly programming for Linux x86_64 🎉. I hope you enjoyed it and learned something new. Reaching this point is a big achievement — so my congratulations!

Thank you for taking this journey with me. Keep experimenting, keep breaking and fixing things, and what is the most importantly — have a fun during coding 🚀
