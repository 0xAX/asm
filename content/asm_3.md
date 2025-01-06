# Journey through the stack

In the [previous post](asm_2.md) we started to learn the basics of the x86_64 architecture. Amonth others, one of the most crucial concept that we have learned in the previous chapter was - [stack](https://en.wikipedia.org/wiki/Stack-based_memory_allocation). In this chapter we are going to dive deeper into fundamental concepts and see the more examples of the stack usage.

Let's start with a little reminder - the stack is special region in memory, which operates on the principle lifo (Last Input, First Output). We have sixtheen general-purpose registers which we can use as for the temporary data storage. They are `rax`, `rbx`, `rcx`, `rdx`, `rdi`, `rsi`, `rbp`, `rsp` and from `r8` to `r15`. It might be too few for the applications. One of the way how to avoid this limitation is usage of the stack. 

Besides the temporary storage for data, the another crucial usage of the stack is ability to call and return from the [functions](https://en.wikipedia.org/wiki/Function_(computer_programming)). When we call a function, return address stored on the stack. After end of the function execution, the return address copied back into the `rip` register and execution continues from the address behind the called function.

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
		;; Otherwise, do something else
		;;

incRax:
        ;; Increment the value of the rax register
		inc rax
        ;; Return from the incRax subroutine
		ret
```

In the small example above, we can see that after the program start, the value `1` is stored in the of the rax registerer. Then we call the subroutine `incRax`, which increases values of the rax register by 1. As soon as the value of the rax register is increased, the sobrutine is ended with the `ret` instruction and execution continues from the instructions that are located right behind the call of the `incRax` subroutine.

Besides the preserving of the return address, stack is used to access parameters of the function and local variables. From the previous chapter, you can remember that according to the [System V AMD64 ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf) document, the first six parameters of a function passed in registers. 

These registers are:

- `rdi` - used to pass the first argument to a function.
- `rsi` - used to pass the second argument to a function.
- `rdx` - used to pass the third argument to a function.
- `r10` - used to pass the fourth argument to a function.
- `r8` - used to pass the fifth argument to a function.
- `r9` - used to pass the sixth argument to a function.

Local variables are also accessed using the stack. For example let's take a look at the following trivial function written in C that doubles its parameter:

```C
int __double(int a) {
    int two = 2;

    return a * two;
}
```

If we will compile this function and take a look at the assembly output, we will see something like this:

```asssembly
__double(int):
        ;; Preserve the base pointer
        push    rbp
        ;; Set the new frame base pointer
        mov     rbp, rsp
        ;; Put the value of the first parameter of the function from the edi register on the stack with the location rbp - 20 bytes.
        mov     DWORD PTR [rbp-20], edi
        ;; Put the 2 to on the stack with the location rbo - 4 bytes.
        mov     DWORD PTR [rbp-4], 2
        ;; Put the values of the first parameter of the function to the eax register.
        mov     eax, DWORD PTR [rbp-20]
        ;; Multiple the value of the eax register to 2 and store the result in the eax register.
        imul    eax, DWORD PTR [rbp-4]
        ;; Restore base pointer.
        pop     rbp
        ;; Exit from the __dobule function.
        ret
```

After the first two lines of the `__double` function the stack frame for this function is set and looks like:

TODO diagram

The third instruction of the function `__double` puts the first parameter of this function to the stack with offset `-20`. After this we may see that the value `2` which is the value of the local variable `two` is also put onto the stack with the offset `-4`. The stack frame of our function for this moment should look like this: 

TODO diagram

After this we put the value from the stack with the offset `-20` (the value of the functions' parameter) to the register eax and multiply it by `2` which is located on the stack with the offset `-4`. The result of the multiplication will be in the register eax. This simple example shows how stack is used to access and parameters and local variables of the function.

## Security considerations

TODO: example of vulnerabilities and protection
https://github.com/colmmacc/CVE-2022-3602

## Stack operations

We already have seen two assembly instructions that affects the current state of the stack:

- `push` - pushes the operand into the stack.
- `pop` - pops the top value from the stack.

x86_64 processors provide additional instruction that brings affect on the stack. Besides those instruction we also have seen familar to us:

- `call`
- `ret`

The first one instruction calls the given procedure. It affects stack by saving the return address on the stack before call. The second instruction is an "exit" from the given procedure. It affects the stack by removing the return address from the stack and transfering the execution flow to it. 

In the [previous post](asm_2.md) we got familar with the with such a concepts as [function prologue and eplogue](https://en.wikipedia.org/wiki/Function_prologue_and_epilogue). These are special instructions that we usually can meet in the beginning and in the end of the function:

```assembly
foo:
        ;; Function prologue
        push %rbp
        mov     rbp, rsp

        ;;
        ;; Function body
        ;;

        ;; Function epilogue
        mov rsp, rbp
        pop
```

These two could be replcaed with special instructions: `enter N, 0` and `leave`. The first isntruction has two operands: 

- Number of bytes that needs to be substracted from the `rsp` register to allocate space on stack.
- Number of levels of stack frames in nested calls.

These both instructions are considered "outdated" but still will work because of backward compatibility.

The next already familar to us instruction that affects the stack is the `syscall` instruction. In some aspects it is similar to the `call` instruction with the one of the most significant difference is that the function that is going to be called is located in the kernel space. The return from a system call and the stack clean-up is executed with the help of the `sysret` instruction.

In the previous post, we mentioned that besides the general purpose registers, the other types of registers exists. One of such type of registers is `rflags`. In basic words it is a register where CPU stores its current state. In the next posts we will know more details about this type of register but for now we must know that an x86_64 process provide the two following command that affect the stack:

- `pushf` - pushes the `rflags` register into the stack.
- `popf` - pops the top value from the stack and stores the value in the `rflags` register.

## Example

After we went through some theory it is time to write some code! Let's see another one example that should make us more confident with the assembly programming. This time we will write a simple program, which will get [two command line arguments](https://en.wikipedia.org/wiki/Command-line_interface#Arguments), try to calculate sum of the given values and print the result.

> [!NOTE]
> For the sake of simplification we will skip the check that numeric values are given in the command line arguments and do not do any checks for overflow. You may do it as your homework.

Before any explanation, first of all let's take a look at the whole code:

```assembly
;; Definition of the .data section
section .data
    ;; Number of `sys_write` system call
	SYS_WRITE equ 1
    ;; Number of `sys_exit` system call
	SYS_EXIT equ 60
    ;; Number of the standard output file descriptor
	STD_OUT	equ 1
    ;; Exit code from the program. The 0 status code is success
	EXIT_CODE equ 0
    ;; ASCII code of the new line symbol ('\n')
	NEW_LINE db 0xa
    ;; Error message that is printed in a case of not enough command line arguments
	WRONG_ARGC_MSG	db "Error: expected two command line argument", 0xa
    ;; Length of the WRONG_ARGC_MSG message
    WRONG_ARGC_MSG_LEN equ 42

;; Definition of the .text section
section .text
    ;; Reference to the entry point of our program
	global	_start

;; Entry point
_start:
	;; Fetch the number of arguments from the stack and store it in the rcx register
	pop rcx
    ;; Check the number of the given command line arguments.
	cmp rcx, 3
    ;; If not enough, jump to error subroutine.
	jne argcError

	;; Skip the first command line argument which is usually the program name.
	add rsp, 8

	;; Fetch the first command line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the first command line argument to an integer number.
	call str_to_int
	;; Store the result in the r10 register.
	mov r10, rax

	;; Fetch the second command line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the second command line argument to an integer number.
	call str_to_int
	;; Store the result in the r11 register.
	mov r11, rax

	;; Calculate the sum of the arguments. The result will be stored in the r10 register.
	add r10, r11

    ;; Move sum value to the rax register.
	mov rax, r10
	;; Initialize counter by resetting it to 0. It will store the length of the result string.
	xor rcx, rcx
	;; Convert the sum from number to string to print the result on the screen.
	jmp int_to_str

;; Print the error message if not enough command line arguments.
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

;; Convert the command line argument to the integer number.
str_to_int:
	;; Set the value of the rax register to 0. It will store the result.
	xor rax, rax
	;; base for multiplication
	mov	rcx,  10
__repeat:
	;; Check the first element in the given string by comparison it with the NUL terminator (end of string).
	cmp [rsi], byte 0
	;; If we reached the end of the string return from the procedure. The result is stored in the rax register.
	je __return
	;; Move the current character from the command line argument to the bl register.
	mov bl, [rsi]
	;; Substract the value 48 from the ASCII code of the current character.
    ;; This will give us numberic value of the character.
	sub bl, 48
	;; Multiple our result number by 10 to get the place for the next digit.
	mul rcx
	;; Add the next digit to our result number.
	add	rax, rbx
	;; Move to the next character in the command line argument string.
	inc	rsi
	;; Repeat while we did not reach the end of string.
	jmp	__repeat
__return:
    ;; Return from the str_to_int procedure.
	ret

;; Convert the sum to string and print on the screen.
int_to_str:
	;; High part of dividend. The low part is in the rax register.
	mov rdx, 0
	;; Set the divisor to 10.
	mov rbx, 10
	;; Divide the sum (rax from rax) to 10. Reminder will be stored in the rdx register.
	div rbx
	;; Add 48 to the reminder to get string ASCII representation of the number value.
	add rdx, 48
	;; Store reminder on the stack.
	push rdx
	;; Increase the counter.
	inc rcx
	;; Compare the rest of the sum with zero.
	cmp rax, 0x0
	;; If it is not zero yet, continue to convert it to string.
	jne int_to_str
	;; Otherwise print the result.
	jmp printResult

;; Print result to the standard output.
printResult:
	;; Put the number of symbols within the string to the rax register.
    mov rax, rcx
    ;; Put the value 8 to the rcx register.
    mov rcx, 8
    ;; Calculate the number of bytes in the given string by multiplication rax to 8.
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
	;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
	mov rdi, EXIT_CODE
	;; Call the `sys_exit` system call.
	syscall
```

Yes I know, this example looks quite big for a such simple problem 😨. But do not worry. The code itself should be documented pretty well with the comments. But let's go through its parts and try to understand how it works.

### Definition of variables

In the beginning of our program we may see already traditional definition of the `.data` section:

```assembly
section .data
    ;; Number of `sys_write` system call
	SYS_WRITE equ 1
    ;; Number of `sys_exit` system call
	SYS_EXIT equ 60
    ;; Number of the standard output file descriptor
	STD_OUT	equ 1
    ;; Exit code from the program. The 0 status code is success
	EXIT_CODE equ 0
    ;; ASCII code of the new line symbol ('\n')
	NEW_LINE db 0xa
    ;; Error message that is printed in a case of not enough command line arguments
	WRONG_ARGC_MSG	db "Error: expected two command line argument", 0xa
    ;; Length of the WRONG_ARGC_MSG message
    WRONG_ARGC_MSG_LEN equ 42
```

As we know from the previous posts, the main purpose of the `data` section is to define variables that have initialized values. This example is not an exception. We may see the definition of the system call numbers variables, string error messages and so on. This part is very well commented and everything should be clear in general. If you feel that you do not understand something it is better to return to the previous posts and clarify before you will proceed with the rest of explanation.

### Handling command line arguments

Before we are able to get the sum of two numbers that will come from the command line arguments, we should know how to handle command line arguments in our programs. According to the [System V Application Binary Interface](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf), the initial stack state of the process right after this process was launched is following: 

| Purpose                                                                           | Start Address      | Length            |
|-----------------------------------------------------------------------------------|--------------------|-------------------|
| Unspecified                                                                       | High Addresses     |                   |
| Informatiion block, including argument/environment strings, auxilariy information |                    | varies            |
| Unspecified                                                                       |                    |                   |
| Null auxiliary vector entry                                                       |                    | 1 eightbyte       |
| Auxiliary vector entries...                                                       |                    | 2 eightbytes each |
| 0                                                                                 |                    | eightbyte         |
| Environment pointers ...                                                          |                    | 1 eightbyte each  |
| 0                                                                                 | 8 + 8 * argc + rsp | eightbyte         |
| Argument pointers                                                                 | 8 + rsp            | argc eightbytes   |
| Argument count                                                                    | rsp                | eightbyte         |
| Undefined                                                                         | Low Addresses      |                   |

As we may see number of command line arguments that was passed to the program is on the top of the stack and the `rsp` register points to it. So, fetching the value from the stack will give us the number of arguments. Besides that we already know the `cmp` instruction which allows us to compare two values. Using this knowledge we can do the very first check in our program - to check that our program got two arguments from command line or print error message otherwise:

```assembly
;; Definition of the .text section
section .text
    ;; Reference to the entry point of our program
	global	_start

;; Entry point
_start:
	;; Fetch the number of arguments from the stack and store it in the rcx register
	pop rcx
    ;; Check the number of the given command line arguments.
	cmp rcx, 3
    ;; If not enough, jump to error subroutine.
	jne argcError

;; Print the error message if not enough command line arguments.
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

Note that despite we expect to get two command line arguments, we are comparing the actual number with `3`. This is done because the first implicit argument of each program is the program name.

After we have made sure that the required number of command line arguments has been passed to our program, we can start with handling of them. But what basically do we need to handle them? We need to execute the following actions:

- Convert the given command line arguments to integer numbers and calculate the sum of the given numbers.
- Convert the result back to string and print it on the screen.

In the next two sections we will see detailed explanation of the steps mentioned above.

### Converting string to integer

Since the command line arguments of each program represented as strings, we need to convert our command line arguments to numbers to calculate their sum. To convert a given string to a number we will use a simple algorithm:

1. Create an accumulator that will be a result - the numeric representation of the given string.
2. We will take first byte of the string and substract from it the value `48`. Each byte in a string is an [ASCII](https://en.wikipedia.org/wiki/ASCII) symbol that has own code. The symbol `'0'` has code `48`, the symbol `'1'` has code 49, and so on. If we will substract `48` from the ASCII code of the given symbol we will get integer representation of the current digit from the given string.
3. As soon as we know the current digit, we multiple our accumulator from the step 1 by 10 and add to it the digit that we got during the step 2.
4. Move to the next symbol in the given string and repeat the steps 2 and 3 if it is not end of the string (`\0` symbol).

Returning to the table from the section above, we may see that pointers to the command line arguments are located on the stack right above the number of command line arguments. So if we fetch the first value from the stack after we already fetched the number of arguments, it will be a pointer to the string which is the first command line argument. If we will pop the next value from the stack, it will be the second command line argument passed to the program.

Now if we will take a look at the `str_to_int` procedure it should be clear without any additional details:

```assembly
	;; Fetch the first command line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the first command line argument to an integer number.
	call str_to_int
	;; Store the result in the r10 register.
	mov r10, rax

	;; Fetch the second command line argument from the stack and store it in the rsi register.
	pop rsi
	;; Convert the second command line argument to an integer number.
	call str_to_int
	;; Store the result in the r11 register.
	mov r11, rax
    
    ...
    ...
    ...

;; Convert the command line argument to the integer number.
str_to_int:
	;; Set the value of the rax register to 0. It will store the result.
	xor rax, rax
	;; base for multiplication
	mov rcx,  10
__repeat:
	;; Check the first element in the given string by comparison it with the NUL terminator (end of string).
	cmp [rsi], byte 0
	;; If we reached the end of the string return from the procedure. The result is stored in the rax register.
	je __return
	;; Move the current character from the command line argument to the bl register.
	mov bl, [rsi]
	;; Substract the value 48 from the ASCII code of the current character.
    ;; This will give us numberic value of the character.
	sub bl, 48
	;; Multiple our result number by 10 to get the place for the next digit.
	mul rcx
	;; Add the next digit to our result number.
	add rax, rbx
	;; Move to the next character in the command line argument string.
	inc rsi
	;; Repeat while we did not reach the end of string.
	jmp __repeat
__return:
    ;; Return from the str_to_int procedure.
	ret
```

As soon as we converted both command line arguments to integer numbers, we can calculate their sum:

```assembly
	;; Calculate the sum of the arguments. The result will be stored in the r10 register.
	add r10, r11
```

Since we have our result, we just need to print it. But before printing it we have to convert the numeric result to string. This we will see in the next section.

### Converting integer to string

In the end of the previous section we calculated the sum of two numbers and put the result in the `r10` register. The `sys_write` system call can print only string. So we need to convert our numeric sum to string before we can print it. We will achieve this by the `int_to_str` sobrutine:

```assembly
    ;; Move sum value to the rax register.
	mov rax, r10
	;; Initialize counter by resetting it to 0. It will store the length of the result string.
	xor rcx, rcx
	;; Convert the sum from number to string to print the result on the screen.
	jmp int_to_str

;; Convert the sum to string and print on the screen.
int_to_str:
	;; High part of dividend. The low part is in the rax register.
    ;; The div instruction works as div operand => rdx:rax / operand. 
    ;; The reminder is stored in rdx and the quotient in rax.
	mov rdx, 0
	;; Set the divisor to 10.
	mov rbx, 10
	;; Divide the sum (rax from rax) to 10. Reminder will be stored in the rdx register.
	div rbx
	;; Add 48 to the reminder to get string ASCII representation of the number value.
	add rdx, 48
	;; Store reminder on the stack.
	push rdx
	;; Increase the counter.
	inc rcx
	;; Compare the rest of the sum with zero.
	cmp rax, 0x0
	;; If it is not zero yet, continue to convert it to string.
	jne int_to_str
	;; Otherwise print the result.
	jmp printResult
```

Before jumping to the `int_to_str` sobrutine, we need to do some preparations. As you may see we put the value of our sum in the `rax` register and initialize the counter (`rcx` register) with zero. This counter will store the number of symbols in the our future string. Note that we are using new instruction to initialize the counter - `xor`. This instruction is a [bitwise XOR](https://en.wikipedia.org/wiki/Bitwise_operation#XOR) operator which resets bits of the operands to 0 if they are the same.

The algorithm of the `int_to_str` sobrutine is pretty simple as well. We divide our number by `10` to get the digit and add the value `48` to the result of division. Remember about ASCII codes? If yes it should be clear why we are doing it. As soon as we got the symbolic representation of the current digit we push it on the stack. As soon as the given digit is converted we increase our counter of numbers of symbols within the string and check our sum number. If it is zero it means we have the resulted string. If not, we just repeat the all operations.

As soon as we will collect all the digits of our sum, they will be stored on the stack. So we can print our string with the following code:

```assembly
;; Print result to the standard output.
printResult:
	;; Put the number of symbols within the string to the rax register.
    mov rax, rcx
    ;; Put the value 8 to the rcx register.
    mov rcx, 8
    ;; Calculate the number of bytes in the given string by multiplication rax to 8.
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
	;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
	mov rdi, EXIT_CODE
	;; Call the `sys_exit` system call.
	syscall
```

Most of this code should be already well understable for you as the most significant part of it consists of the initialization of data for the call of the `sys_write` and `sys_exit` exit calls. The most interesting part should be first four lines of code of the `printResult` subroutine. As you may remember the one of the parameters of the `sys_write` system call is a length of the string that we want to print on the screen. We have this number as we maintained a counter of symbols during converting the numeric sum to the string. This counter was stored in the `rcx` register. Our string is located on the stack. We pushed each digit with the `push` operator. But the `push` operator pushes `64` bits (or `8` bytes) while our symbol is only 1 byte. To get the whole length of the string for printing, we should multiple the number of symbols to `8`. This will give us the length of the string that we can use as a third argument of the `sys_write` system call.

As soon as all parameters of the system calls are ready, we can pass them as arguments to print the sum and print new line after it.

Let's build our program with the usual commands:

```bash
$ nasm -f elf64 -o stack.o stack.asm
$ ld -o stack stack.o
```

And try to run it:

```bash
$  ./stack
Error: expected two command line argument
$ ./stack 5
Error: expected two command line argument
$ ./stack 5 10
15
```

Works as expected 🎉🎉🎉

## Conclusion

We’ve just written our third program using assembly — great job 🎉 In the next post, we’ll continue exploring assembly programming and see more details how to work with strings. If you have any questions or thoughts, feel free to reach out. See you in the next post!

