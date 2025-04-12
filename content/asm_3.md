# Journey through the stack

In the [previous post](asm_2.md), we started to learn the basics of the x86_64 architecture. One of the most crucial concepts we learned was the [stack](https://en.wikipedia.org/wiki/Stack-based_memory_allocation). In this chapter, we will explore more examples of stack usage.

Let's start with a quick reminder: the stack is a special memory region that operates on the LIFO (last-in, first-out) principle. In the x86_64 architecture, we have sixteen general-purpose registers for temporary data storage: `rax`, `rbx`, `rcx`, `rdx`, `rdi`, `rsi`, `rbp`, `rsp`, and from `r8` to `r15`. However, for some applications, this might not be enough. One way to overcome this limitation is by using the stack.

Besides temporary data storage, another crucial use of the stack is the ability to call and return from the [functions](https://en.wikipedia.org/wiki/Function_(computer_programming)). When we call a function, the return address is stored on the stack. Once the function finishes execution, this return address is restored into the `rip` register and the program continues execution from the address following the called function.

For example:

```assembly
global _start

section .text

_start:
	;; Put 1 to the rax register
	mov rax, 1
	;; Call the incRax subroutine
	call incRax
	;; Compare the value in the rax register with 2
	cmp rax, 2
	;; Jump to the 'exit' label if not equal
	jne exit
	;;
	;; Otherwise, perform another action.
	;;

incRax:
	;; Increment the value of the rax register
	inc rax
	;; Return from the incRax subroutine
	ret
```

In the example above, we can see that after the program starts, the value `1` is stored in the `rax` register. Next, we call the subroutine `incRax`, which increases the value in the `rax` register by 1. After updating the `rax` register, the subroutine ends with the `ret` instruction, and execution continues with the instructions immediately following the call to the `incRax` subroutine.

In addition to preserving the return address, the stack is also used to access the function parameters and local variables. As you may recall from the previous chapter, the [System V AMD64 ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf) document specifies that the first six function parameters are passed in registers.

These registers are:

- `rdi` - used to pass the first argument to a function.
- `rsi` - used to pass the second argument to a function.
- `rdx` - used to pass the third argument to a function.
- `r10` - used to pass the fourth argument to a function.
- `r8` - used to pass the fifth argument to a function.
- `r9` - used to pass the sixth argument to a function.

Local variables are also accessed using the stack. For example, let's take a look at the following C function that doubles its parameter:

```C
// The "__" prefix in the `__double` function name is used to avoid confusion with the `double` data type.
int __double(int a) {
    int two = 2;

    return a * two;
}
```

If we compile this function and take a look at the assembly output, we will see something like this:

```assembly
__double(int):
	;; Preserve the base pointer
	push rbp
	;; Set the new frame base pointer
	mov rbp, rsp
	;; Put the value of the first parameter of the function from the edi register
	;; on the stack with the location rbp - 20 bytes.
	mov DWORD PTR [rbp-20], edi
	;; Put 2 to on the stack with the location rbp - 4 bytes.
	mov DWORD PTR [rbp-4], 2
	;; Put the value of the first function parameter to the eax register.
	mov eax, DWORD PTR [rbp-20]
	;; Multiple the value of the eax register to 2 and store the result in the eax register.
	imul eax, DWORD PTR [rbp-4]
	;; Restore base pointer.
	pop rbp
	;; Exit from the __dobule function.
	ret
```

After the first two lines of the `__double` function, the stack frame for this function is set and looks like this:

![asm-3-stack-fram-of__double-1](./assets/asm-3-stack-of__double-1.svg)

The third instruction of the `__double` function places its first parameter to the stack with an offset of `-20`. Next, the value `2`, representing the local variable two, is also stored on the stack with an offset of `-4`. At this point, the stack frame of our function looks like this:

![asm-3-stack-fram-of__double-2](./assets/asm-3-stack-of__double-2.svg)

Finally, we put the value from the stack at offset `-20` (the value of the function's parameter) into the `eax` register and multiply it by `2`, which is located on the stack at offset `-4`. The result of the multiplication is then stored in the `eax` register. This simple example shows how the stack is used to access both parameters and local variables of a function.

## Stack operations

We've already seen two assembly instructions that affect the current state of the stack:

- `push` - pushes the operand into the stack.
- `pop` - pops the top value from the stack.

x86_64 processors provide additional instructions that affect the stack. In addition to these, we’ve also seen instructions that are already familiar to us:

- `call` - calls the given procedure. It affects the stack by saving the return address before the call.
- `ret` - exits the given procedure. It affects the stack by removing the return address and transferring the execution flow back to it.

In the [previous post](asm_2.md), we became familiar with concepts such as the [function prologue and epilogue](https://en.wikipedia.org/wiki/Function_prologue_and_epilogue). These are special instructions typically found at the beginning and end of a function:

```assembly
foo:
	;; Function prologue
	push rbp
	mov  rbp, rsp

	;;
	;; Function body
	;;

	;; Function epilogue
	mov rsp, rbp
	pop
```

These two can be replaced with special instructions: `enter N, 0` and `leave`. The `enter` instruction has two operands:

- Number of bytes to subtract from the `rsp` register to allocate space on the stack.
- Number of stack frame levels in nested calls.

These instructions are considered "outdated" due to performance issues, and the usual function prologue and epilogue are typically used instead. However, these instructions still work for backward compatibility.

The next familiar instruction that affects the stack is the `syscall` instruction. In some aspects, it is similar to the `call` instruction, with one key difference: the function to be called is located in kernel space. The return from a system call and the stack clean-up are executed using the `sysret` instruction.

In the previous post, we mentioned that there are other types of registers besides the general purpose registers. One such register is `rflags` where the CPU stores its current state. In the next posts, we will learn more about it. For now, we must know that the x86_64 processor provides the following two commands that affect the stack:

- `pushf` - pushes the `rflags` register into the stack.
- `popf` - pops the top value from the stack and stores it in the `rflags` register.

## Example

After going through the theory, it’s time to write some code! Let’s explore another example to boost our confidence with assembly programming. In the previous chapter, we wrote the [assembly program](./asm_2.md#program-example) that calculated the sum of two numbers that were hard-coded in the program's code. Now, let's do something similar but less trivial. This time, we will write a simple program that takes two [command-line arguments](https://en.wikipedia.org/wiki/Command-line_interface#Arguments), calculates their sum, and prints the result.

> [!NOTE]
> For simplification, we will skip checking whether the command-line arguments are numeric and won’t handle overflow checks. You can do it as your homework.

Before diving into details, let's first examine the entire code:

```assembly
;; Definition of the .data section
section .data
	;; Number of the `sys_write` system call
	SYS_WRITE equ 1
	;; Number of the `sys_exit` system call
	SYS_EXIT equ 60
	;; Number of the standard output file descriptor
	STD_OUT	equ 1
	;; Exit code from the program. The 0 status code is a success.
	EXIT_CODE equ 0
	;; ASCII code of the new line symbol ('\n')
	NEW_LINE db 0xa
	;; Error message that is printed in a case of not enough command-line arguments
	WRONG_ARGC_MSG	db "Error: expected two command-line arguments", 0xa
	;; Length of the WRONG_ARGC_MSG message
	WRONG_ARGC_MSG_LEN equ 42

;; Definition of the .text section
section .text
	;; Reference to the entry point of our program
	global	_start

;; Entry point
_start:
	;; Fetch the number of arguments from the stack and store it in the rcx register.
	pop rcx
	;; Check the number of the given command-line arguments.
	cmp rcx, 3
	;; If not enough, jump to the error subroutine.
	jne argcError

	;; Skip the first command-line argument which is usually the program name.
	add rsp, 8

	;; Fetch the first command-line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the first command-line argument to an integer number.
	call str_to_int
	;; Store the result in the r10 register.
	mov r10, rax

	;; Fetch the second command-line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the second command-line argument to an integer number.
	call str_to_int
	;; Store the result in the r11 register.
	mov r11, rax

	;; Calculate the sum of the arguments. The result will be stored in the r10 register.
	add r10, r11
	;; Move the sum value to the rax register.
	mov rax, r10
	;; Initialize counter by resetting it to 0. It will store the length of the result string.
	xor rcx, rcx
	;; Convert the sum from a number to a string to print the result to the standard output.
	jmp int_to_str

;; Print the error message if not enough command-line arguments.
argcError:
	;; Specify the system call number (1 is `sys_write`).
	mov rax, SYS_WRITE
	;; Set the first argument of `sys_write` to 1 (`stdout`).
	mov rdi, STD_OUT
	;; Set the second argument of `sys_write` to the reference of the `WRONG_ARGC_MSG` variable.
	mov rsi, WRONG_ARGC_MSG
	;; Set the third argument to the length of the `WRONG_ARGC_MSG` variable's value.
	mov rdx, WRONG_ARGC_MSG_LEN
	;; Call the `sys_write` system call.
	syscall
	;; Go to the exit of the program.
	jmp exit

;; Convert the command-line argument to the integer number.
str_to_int:
	;; Set the value of the rax register to 0. It will store the result.
	xor rax, rax
	;; Base for multiplication
	mov rcx,  10
__repeat:
	;; Compare the first element in the given string with the NUL terminator (end of the string).
	cmp [rsi], byte 0
	;; If we reached the end of the string, return from the procedure. The result is stored in the rax register.
	je __return
	;; Move the current character from the command-line argument to the bl register.
	mov bl, [rsi]
	;; Subtract the value 48 from the ASCII code of the current character.
	;; This will give us the numeric value of the character.
	sub bl, 48
	;; Multiple our result number by 10 to get the place for the next digit.
	mul rcx
	;; Add the next digit to our result number.
	add rax, rbx
	;; Move to the next character in the command-line argument string.
	inc rsi
	;; Repeat until we reach the end of the string.
	jmp __repeat
__return:
	;; Return from the str_to_int procedure.
	ret

;; Convert the sum to a string and print it to the standard output.
int_to_str:
	;; High part of the dividend. The low part is in the rax register.
	mov rdx, 0
	;; Set the divisor to 10.
	mov rbx, 10
	;; Divide the sum stored in `rax`, resulting quotient will be stored in `rax`,
	;; and the reminder will be stored in `rdx` register.
	div rbx
	;; Add 48 to the reminder to get a string ASCII representation of the number value.
	add rdx, 48
	;; Store the reminder on the stack.
	push rdx
	;; Increase the counter.
	inc rcx
	;; Compare the rest of the sum with zero.
	cmp rax, 0x0
	;; If it is not zero, continue to convert it to string.
	jne int_to_str
	;; Otherwise, print the result.
	jmp printResult

;; Print the result to the standard output.
printResult:
	;; Put the number of string characters to the rax register.
	mov rax, rcx
	;; Put the value 8 to the rcx register.
	mov rcx, 8
	;; Calculate the number of bytes in the given string by multiplying rax by 8.
	;; The result will be stored in the rax register.
	mul rcx

	;; Set the third argument to the length of the result string to print.
	mov rdx, rax
	;; Specify the system call number (1 is `sys_write`).
	mov rax, SYS_WRITE
	;; Set the first argument of `sys_write` to 1 (`stdout`).
	mov rdi, STD_OUT
	;; Set the second argument of `sys_write` to the reference of the result string to print.
	mov rsi, rsp
	;; Call the `sys_write` system call.
	syscall

	;; Specify the system call number (1 is `sys_write`).
	mov rax, SYS_WRITE
	;; Set the first argument of `sys_write` to 1 (`stdout`).
	mov rdi, STD_OUT
	;; Set the second argument of `sys_write` to the reference of the `NWE_LINE` variable.
	mov rsi, NEW_LINE
	;; Set the third argument to the length of the `NEW_LINE` variable's value (1 byte).
	mov rdx, 1
	;; Call the `sys_write` system call.
	syscall

exit:
	;; Specify the number of the system call (60 is `sys_exit`).
	mov rax, SYS_EXIT
	;; Set the first argument of `sys_exit` to 0. The 0 status code is a success.
	mov rdi, EXIT_CODE
	;; Call the `sys_exit` system call.
	syscall
```

Yes, this example might seem quite big for such a simple problem 😨 But do not worry — the code is well-documented with comments. Let’s go through its parts and understand how it works.

### Definition of variables

At the beginning of our program, we can see a typical definition of the `.data` section:

```assembly
section .data
	;; Number of the `sys_write` system call
	SYS_WRITE equ 1
	;; Number of the `sys_exit` system call
	SYS_EXIT equ 60
	;; Number of the standard output file descriptor
	STD_OUT	equ 1
	;; Exit code from the program. The 0 status code is a success.
	EXIT_CODE equ 0
	;; ASCII code of the new line symbol ('\n')
	NEW_LINE db 0xa
	;; Error message that is printed in a case of not enough command-line arguments
	WRONG_ARGC_MSG	db "Error: expected two command-line argument", 0xa
	;; Length of the WRONG_ARGC_MSG message
	WRONG_ARGC_MSG_LEN equ 42
```

As we know from the previous posts, the main purpose of the `data` section is to define variables that have initialized values. This example is no exception. Here, we define the system call number variables, string error messages, and more. This code sample contains comments with descriptions, so everything should generally be clear. If something is unclear, it’s a good idea to revisit the previous posts for clarification before you proceed with the rest of the explanation.

### Handling command-line arguments

Before calculating the sum of two numbers from the command-line arguments, we need to understand how to handle command-line arguments in our programs. Pointers to the command-line arguments are located on the stack. To access them, we need to know the offset from the top of the stack. To learn where the command-line arguments of a Linux program are located on the stack, it's good to read the [System V Application Binary Interface](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf). According to this document, the initial stack layout of a program immediately after launch is as follows:

| Purpose                                                                           | Start Address      | Length            |
|-----------------------------------------------------------------------------------|--------------------|-------------------|
| Unspecified                                                                       | High Addresses     |                   |
| Information block, including argument/environment strings, auxiliary information  |                    | varies            |
| Unspecified                                                                       |                    |                   |
| Null auxiliary vector entry                                                       |                    | 1 eightbyte       |
| Auxiliary vector entries...                                                       |                    | 2 eightbytes each |
| 0                                                                                 |                    | eightbyte         |
| Environment pointers ...                                                          |                    | 1 eightbyte each  |
| 0                                                                                 | 8 + 8 * argc + rsp | eightbyte         |
| Argument pointers                                                                 | 8 + rsp            | argc eightbytes   |
| Argument count                                                                    | rsp                | eightbyte         |
| Undefined                                                                         | Low Addresses      |                   |

According to the table above, the command-line arguments are located on the stack like this:

![asm-3-args-on-stack](./assets/asm-3-args-on-stack.svg)

As we can see, the number of command-line arguments passed to the program is stored at the top of the stack, with the `rsp` register pointing to it. Fetching this value from the stack gives us the number of arguments. Additionally, we already know the `cmp` instruction, which allows us to compare two values. Using this knowledge, we can perform the first check in our program — verifying that the program got two arguments from the command-line or printing an error message otherwise:

```assembly
;; Definition of the .text section
section .text
	;; Reference to the entry point of our program
	global	_start

;; Entry point
_start:
	;; Fetch the number of arguments from the stack and store it in the rcx register.
	pop rcx
	;; Check the number of the given command-line arguments.
	cmp rcx, 3
	;; If not enough, jump to the error subroutine.
	jne argcError

;; Print the error message if not enough command-line arguments.
argcError:
	;; Specify the system call number (1 is `sys_write`).
	mov rax, SYS_WRITE
	;; Set the first argument of `sys_write` to 1 (`stdout`).
	mov rdi, STD_OUT
	;; Set the second argument of `sys_write` to the reference of the `WRONG_ARGC_MSG` variable.
	mov rsi, WRONG_ARGC_MSG
	;; Set the third argument to the length of the `WRONG_ARGC_MSG` variable's value.
	mov rdx, WRONG_ARGC_MSG_LEN
	;; Call the `sys_write` system call.
	syscall
	;; Go to the exit of the program.
	jmp exit
```

Note that although we expect two command-line arguments, we compare the actual number with `3`. This is because the first implicit argument for every program is its name.

After making sure that the required number of command-line arguments are passed to our program, we can start working with them. But what do we need to do? Here are the steps:

1. Convert the given command-line arguments to integer numbers and calculate their sum.
2. Convert the result back to a string and print it to the standard output.

In the next two sections, we will see a detailed explanation of these steps.

### Converting a string to an integer

As the command-line arguments of each program are represented as strings, first we need to convert our command-line arguments to numbers to calculate their sum. To convert a given string to a number, we will use a simple algorithm:

1. Create an accumulator to store an intermediate result while converting the string into its numeric representation.
2. Take the first byte of the string and subtract the value `48` from it. Each byte in a string is an [ASCII](https://en.wikipedia.org/wiki/ASCII) character with its own code. The character 0 has code `48`, the character 1 has code `49`, and so on. If we subtract `48` from the ASCII code of the given character, we get an integer representation of the current digit from the given string.
3. As soon as we know the current digit, we multiply our accumulator from step 1 by 10 and add to it the digit that we got in step 2.
4. Move to the next character in the given string and repeat steps 2 and 3 if it is not the end of the string (`\0` symbol).

Returning to the table from the section above, we can see that pointers to the command-line arguments are located on the stack right above the number of command-line arguments. So, after we pop the number of arguments (ARGC), the stack pointer will point to the address of the first command-line argument (ARGV[0]). If we pop the next value from the stack, it will point to the second command-line argument (ARGV[1]) passed to the program.

Now the `str_to_int` procedure should be more clear:

```assembly
	;; Fetch the first command-line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the first command-line argument to an integer number.
	call str_to_int
	;; Store the result in the r10 register.
	mov r10, rax

	;; Fetch the second command-line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the second command-line argument to an integer number.
	call str_to_int
	;; Store the result in the r11 register.
	mov r11, rax

	...
	...
	...

;; Convert the command-line argument to the integer number.
str_to_int:
	;; Set the value of the rax register to 0. It will store the result.
	xor rax, rax
	;; Base for multiplication
	mov rcx,  10
__repeat:
	;; Compare the first element in the given string with the NUL terminator (end of the string).
	cmp [rsi], byte 0
	;; If we reached the end of the string, return from the procedure. The result is stored in the rax register.
	je __return
	;; Move the current character from the command-line argument to the bl register.
	mov bl, [rsi]
	;; Subtract the value 48 from the ASCII code of the current character.
	;; This will give us the numeric value of the character.
	sub bl, 48
	;; Multiple our result number by 10 to get the place for the next digit.
	mul rcx
	;; Add the next digit to our result number.
	add rax, rbx
	;; Move to the next character in the command-line argument string.
	inc rsi
	;; Repeat until we reach the end of the string.
	jmp __repeat
__return:
	;; Return from the str_to_int procedure.
	ret
```

As soon as we converted both command-line arguments to integer numbers, we can calculate their sum:

```assembly
	;; Calculate the sum of the arguments. The result will be stored in the r10 register.
	add r10, r11
```

Now that we have our result, we just need to print it. But before printing it, we have to convert the numeric result back to a string.

### Converting an integer to a string

In the previous section, we calculated the sum of two numbers and put the result in the `r10` register. As the `sys_write` system call can only print a string, now we need to convert our numeric sum into a string. To do so, we will use the `int_to_str` subroutine:

```assembly
	;; Move the sum value to the rax register.
	mov rax, r10
	;; Initialize counter by resetting it to 0. It will store the length of the result string.
	xor rcx, rcx
	;; Convert the sum from a number to a string to print the result to the standard output.
	jmp int_to_str

;; Convert the sum to a string and print it to the standard output.
int_to_str:
	;; High part of the dividend. The low part is in the rax register.
	;; The div instruction works as div operand => rdx:rax / operand.
	;; The reminder is stored in rdx and the quotient in rax.
	mov rdx, 0
	;; Set the divisor to 10.
	mov rbx, 10
    ;; Divide the sum stored in `rax. The resulting quotient will be stored in `rax`,
	;; and the reminder will be stored in the `rdx` register.
	div rbx
	;; Add 48 to the reminder to get a string ASCII representation of the number value.
	add rdx, 48
	;; Store the reminder on the stack.
	push rdx
	;; Increase the counter.
	inc rcx
	;; Compare the rest of the sum with zero.
	cmp rax, 0x0
	;; If it is not zero, continue to convert it to string.
	jne int_to_str
	;; Otherwise, print the result.
	jmp printResult
```

Before jumping to the `int_to_str` subroutine, we must prepare the data with two instructions:

1. First, we put the value of our sum in the `rax` register using the `mov` instruction.
2. Then, we initialize the counter (`rcx` register) with zero. This counter will store the number of symbols in our future string. To initialize the counter, we use a new instruction - `xor`. This instruction is a [bitwise XOR](https://en.wikipedia.org/wiki/Bitwise_operation#XOR) operator which resets bits of the operands to 0 if they are the same.

The algorithm of the `int_to_str` subroutine is pretty simple. We divide our number by `10` to get the next digit and add the value `48` to the result of the division. Remember about the ASCII codes? If yes, it should be clear why we are doing it: 

1. As soon as we get the symbolic representation of the current digit, we push it on the stack.
2. When the given digit is converted, we increase our counter that represents the number of characters within the string. 
3. After that, we check the sum number. If it is zero, we have the resulting string. If not, we repeat all operations.

Once we collect all the digits of the sum, they will be stored on the stack. Now we can print the string using the following code:

```assembly
;; Print the result to the standard output.
printResult:
	;; Put the number of string characters to the rax register.
	mov rax, rcx
	;; Put the value 8 to the rcx register.
	mov rcx, 8
	;; Calculate the number of bytes in the given string by multiplying rax by 8.
	;; The result will be stored in the rax register.
	mul rcx

	;; Set the third argument to the length of the result string to print.
	mov rdx, rax
	;; Specify the system call number (1 is `sys_write`).
	mov rax, SYS_WRITE
	;; Set the first argument of `sys_write` to 1 (`stdout`).
	mov rdi, STD_OUT
	;; Set the second argument of `sys_write` to the reference of the result string to print.
	mov rsi, rsp
	;; Call the `sys_write` system call.
	syscall

	;; Specify the system call number (1 is `sys_write`).
	mov rax, SYS_WRITE
	;; Set the first argument of `sys_write` to 1 (`stdout`).
	mov rdi, STD_OUT
	;; Set the second argument of `sys_write` to the reference of the `NWE_LINE` variable.
	mov rsi, NEW_LINE
	;; Set the third argument to the length of the `NEW_LINE` variable's value (1 byte).
	mov rdx, 1
	;; Call the `sys_write` system call.
	syscall

exit:
	;; Specify the number of the system call (60 is `sys_exit`).
	mov rax, SYS_EXIT
	;; Set the first argument of `sys_exit` to 0. The 0 status code is a success.
	mov rdi, EXIT_CODE
	;; Call the `sys_exit` system call.
	syscall
```

Most of this code should already be understandable, as it mainly consists of the data initialization for the `sys_write` and `sys_exit` system calls. Both of them we already have seen in two previous chapters. The most interesting part is the first four lines of the `printResult` subroutine. As you may remember, one of the parameters of the `sys_write` system call is the length of the string we want to print to the standard output. We have this number because we maintained a counter of characters while converting the numeric sum to a string. This counter was stored in the `rcx` register. Our string is located on the stack, where we pushed each digit using the `push` instruction. However, the `push` instruction pushes `64` bits (or `8` bytes), while our symbol is only 1 byte. To calculate the total length of the string for printing, we should multiply the number of symbols by `8`. This will give us the length of the string that we can use as the third argument of the `sys_write` system call.

Once all parameters of both system calls are ready, we can pass them as arguments to print the sum followed by a new line.

Now, let's build our program with the usual commands:

```bash
$ nasm -f elf64 -o stack.o stack.asm
$ ld -o stack stack.o
```

Then, try to run it:

```bash
$  ./stack
Error: expected two command-line argument
$ ./stack 5
Error: expected two command-line argument
$ ./stack 5 10
15
```

Works as expected 🎉🎉🎉


## Security considerations

As seen in this and the previous posts, the stack is a crucial concept used to manage function calls in our programs. Understanding how the stack memory is managed is important for writing programs with reusable functions and crucial for writing secure programs. The stack is a common source of security vulnerabilities, especially in low-level code and assembly routines. When you use `call` and `ret` instructions, the processor doesn’t verify if the return address is valid, but it simply pops the address and jumps on it. One of the most common problems is the [stack overflow](https://en.wikipedia.org/wiki/Stack_overflow).

Let's take a look at the simple C function:

```C
#include <stdio.h>
#include <string.h>

void foo() {
    char buffer[8];

    printf("Enter text: ");

    gets(buffer);
}

int main() {
    foo();
    printf("Program exited successfully\n");
    return 0;
}
```

If we build and run this program, we'll see the following error instead of the `Program exited successfully` string:

```bash
$ ./test
Enter text: 123456789
*** stack smashing detected ***: terminated
Aborted (core dumped)
```

The reason for this error is that we put on the stack a value bigger than our 8-byte buffer. Happily, instead of overwriting the return address or segmentation fault error, we get a `stack smashing detected` error. This check is done by a modern compiler to prevent overwriting critical data. There are also other techniques in modern compilers and operating system kernels to mitigate vulnerabilities related to stack, like:

- [Stack canaries](https://en.wikipedia.org/wiki/Buffer_overflow_protection#Canaries)
- [ASLR](https://en.wikipedia.org/wiki/Address_space_layout_randomization)
- [Non-executable stack](https://en.wikipedia.org/wiki/Executable-space_protection)
- And others...

Despite all of these techniques may help you to protect your programs from stack-related errors, you should be careful, especially with the external data that your program receives.

This example might be a little bit artificial as unlikely you are going to use the `gets` function in your code. The [manual page](https://man7.org/linux/man-pages/man3/gets.3.html) of this function says:

> Never use gets().  Because it is impossible to tell without knowing the data in advance how many characters gets() will read, and because gets() will continue to store characters past the end of the buffer, it is extremely dangerous to use.  It has been used to break computer security.  Use fgets() instead.

The real-world case when wrong memory management led to serious consequences is [CVE-2017-1000253](https://nvd.nist.gov/vuln/detail/CVE-2017-1000253). This vulnerability was found in the Linux kernel and led to the [privilege escalation](https://en.wikipedia.org/wiki/Privilege_escalation). When the kernel runs a process, it needs to perform many different operations, such as loading the program into memory and initializing the stack. After the program is loaded and stack initialized, the program is located below the stack memory, with a 128-megabyte gap between them. However, when a large program is loaded, it can overwrite the stack memory. Under certain conditions, it may lead to privilege escalation. If you are interested in more details, you can read the [report](https://www.qualys.com/2017/09/26/linux-pie-cve-2017-1000253/cve-2017-1000253.txt) and the [fix](https://github.com/torvalds/linux/commit/a87938b2e246b81b4fb713edb371a9fa3c5c3c86).

As you can see, subtle bugs in stack layout can lead to serious vulnerabilities.

## Conclusion

We’ve just written our third program using assembly — great job 🎉 In the next post, we’ll continue exploring assembly programming and see more details on how to work with strings. If you have any questions or thoughts, feel free to reach out. See you in the next post!
