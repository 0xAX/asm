# Data manipulation

In the previous chapters, we built a few simple examples and figured out that a basic assembly program consists of just two main things:

- Instructions
- Operands

We also learned that there are different types of instructions, like:

- Data transfer instructions
- Binary arithmetic instructions
- Logical instructions
- Control transfer instructions
- String instructions
- And others, like I/O, flag control, and bit manipulation instructions

We’ve already seen some of them in action, but in this chapter, we’re going to dive a little deeper into how they work — especially when it comes to working with data.

## Data transfer instructions

Data transfer instructions are used to move data between memory and general-purpose registers. One of the most commonly used and familiar instructions is `mov`. We use it to:

- Move data between general-purpose registers
- Move an immediate value to a general-purpose register
- Move data between memory and general-purpose registers

The first two cases are simple. We just specify two general-purpose registers we want to use to move data. For example, to copy the value of the `rcx` register into `rax`, we can use:

```assembly
mov rax, rcx
```

To put value `5` into the `rax` register, we use:

```assembly
mov rax, 5
```

To move data between general-purpose registers and memory, we should use a special syntax with square brackets. For example, to store the value of the `rax` register into the memory address specified by the `rcx` register, use:

```assembly
mov [rcx], rax
```

In addition, extended instructions can be useful when you need to move smaller values into larger registers. These instructions are `movsx` and `movzx`. The purpose of these instructions should be clear if you ask yourself a question: when I move an 8-bit or 16-bit value into a 32-bit or 64-bit register, what should happen to the unused upper bits? The `movzx` instruction fills the upper bits with `0`. The `movsx` instruction copies the [sign bit](https://en.wikipedia.org/wiki/Sign_bit) to the upper bits. In a case of the `movsx` instruction it means that if we move an integer number from a smaller register to a bigger, the upper bits of the bigger register will be filled with `0` if the number was positive and with `1` if negative.

Besides these instructions to move data from one place to another, there are conditional move instructions:

- `cmove` and `cmovne` - Move if the previous comparison operation found that the operands are equal (or not).
- `cmovz` and `cmovnz` - Move if the previous comparison operation found that the result is zero (or not).
- `cmovc` and `cmovnc` - Move if the previous comparison operation set the [carry flag](https://en.wikipedia.org/wiki/Carry_flag) (or not).

For more information about these and other instructions, read the [5.1.1 Data Transfer Instructions chapter of the Intel manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).

For example, the following code moves the value of the `rdx` register to `rax` if they are not equal:

```assembly
cmp rax, rdx
cmovne rax, rdx
```

## Binary arithmetic instructions

We use the decimal arithmetic instructions to operate with integer numbers. We have already seen these instructions in one of the previous chapters:

- `add`  - Addition. It adds the value of the second operand to the first and stores the result in the first operand.
- `sub`  - Subtraction. It subtracts the value of the second operand from the first and stores the result in the first operand.
- `div` and `idiv`  - Unsigned and signed division. Both instructions take a single operand. The value of this operand is divided by the value of the `rax` register. The place where the result is stored depends on the size of the operands. In the case of 8-bit operands, the result is stored in the `al:ah` pair. In the case of 16-bit operands, the result is stored in the `dx:ax` pair. For 32-bit operands, the result is stored in the `edx:eax`, and in the case of 64-bit operands, the result is stored in the `rdx:rax` pair.
- `div` and `idiv`  - Unsigned and signed division. Both instructions take a single operand. The value of this operand is divided by the value of the `rax` register. The place where the result is stored depends on the size of the operands. In the case of 8-bit operands, the result is stored in the `al:ah` pair. In the case of 16-bit operands, the result is stored in the `dx:ax` pair. For 32-bit operands, the result is stored in the `edx:eax`, and in the case of 64-bit operands, the result is stored in the `rdx:rax` pair.
- `inc`  - Increments the value of the first operand.
- `dec`  - Decrements the value of the first operand.
- `neg`  - Negates the value of the first operand.

For example:

```assembly
;; Increment the value of the rcx register
inc rcx

;; Add the value of rcx to rdx
add rdx, rcx
```

## Logical instructions

The logical instructions are used to execute [logical operations](https://en.wikipedia.org/wiki/Boolean_algebra#Operations):

- `and` - The instruction takes two operands and performs the logical *and* operation on them.
- `or` - The instruction takes two operands and performs the logical *or* operation on them.
- `xor` - The instruction takes two operands and performs the logical *xor* operation on them.
- `not` - The instruction takes two operands and performs the logical *not* operation on them.

The result is stored in the first operand.

For example:

```assembly
;; If rax = 1 and rbx = 0, rax stores 0
and rax, rbx

;; If rax = 1 and rbx = 0, rax stores 1
or rax, rbx
```

## Control transfer instructions

We have already seen control transfer instructions in the previous chapters. Normally, the CPU runs a program sequentially, executing instructions one after another. But when we need to change the flow of our program, that’s when control transfer instructions come into play. These instructions are closely bound to the `cmp` instruction, which takes two operands and compares them. Based on the comparison result, one of the special CPU `rflags` registers is set. One of the most common flag bits are:

- `zf` - [zero flag](https://en.wikipedia.org/wiki/Zero_flag). Set if the operands of the `cmp` instruction are equal.
- `cf` - [carry flag](https://en.wikipedia.org/wiki/Carry_flag). Set if the result of an arithmetic instruction is too big to fit the register where it will be stored.
- `sf` - [sign flag](https://en.wikipedia.org/wiki/Negative_flag). Set if the result of an arithmetic instruction produced a value in which the most significant bit is set.
- `df` - [direction flag](https://en.wikipedia.org/wiki/Direction_flag). Set if the strings are processed from highest to lowest address.

The most common control transfer instructions are:

- `jmp` - Jump to the specified address of a program.
- `je` and `jne` - Jump if the previous comparison operation showed that the operands are equal (or not).
- `jz` and `jnz` - Jump if the previous comparison operation set the zero flag to `1` or `0`.
- `jg` and `jl` - Jump if the previous comparison operation resulted in one operand being greater or smaller than another.
- `jge` and `jle` - Jump if the previous comparison operation resulted in one operand being greater (or equal) or smaller (or equal) than another.

For example:

```assembly
;; Compare the values of the rax and rbx registers
cmp rax, rbx
;; Jump if the values are not equal
jne label_if_not_equal
```

## String instructions

Although there is no dedicated data type for strings in assembly, nothing prevents us from storing string-like data in memory and working with it. The `x86_64` CPU architecture provides special instructions designed to operate on such data. Some of these instructions include:

- `movs(b|w|d|q)` - moves a byte, word, doubleword, or quadword (depends on the instruction's postfix) from the source to the destination. The `rsi` registers point to the source string, and the `rdi` registers point to the destination string.
- `cmps(b|w|d|q)` - compares values of two memory locations pointed by the `rsi` and `rdi` registers.
- `scas` - compares a value from a general-purpose register with the value located in the memory address pointed by the `rdi` register.
- `lods` - loads a value pointed by the `rsi` register to a general-purpose register.
- `stos` - stores a value from a general-purpose register into the memory location pointed by the `rdi` register and increments the memory address located there.
- `rep` - repeats one of the instructions above while the value of the `rcx` register is not `0`.

We will see an example of how to use these instructions in the next section.

## Example

Now that we are familiar with more assembly instructions, it's time to write some code! Let's try building an assembly program that reverses a given string. We will print the resulting reversed string to the [standard output](https://en.wikipedia.org/wiki/Standard_streams).

First of all, let's define some static data needed for our program:

```assembly
;; Definition of the .data section
section .data
        ;; Number of the `sys_write` system call.
        SYS_WRITE equ 1
        ;; Number of the `sys_exit` system call.
        SYS_EXIT equ 60
        ;; Number of the standard output file descriptor.
        STD_OUT equ 1
        ;; Exit code from the program. The 0 status code is a success.
        EXIT_CODE equ 0
        ;; Length of the string that contains only the new line symbol.
        NEW_LINE_LEN equ 1

        ;; ASCII code of the new line symbol ('\n').
        NEW_LINE db 0xa
        ;; Input string that we are going to reverse
        INPUT db "Hello world!"
```

Here we can see constants and variables that we will use in our program instead of [magic numbers](https://en.wikipedia.org/wiki/Magic_number_(programming)). Note that we predefine the input string that we will reverse in our program. In the previous chapter, you saw how to handle command-line arguments. As a self-exercise, you can extend this program to take a string and reverse it as a command-line argument.

Next, we define the `.bss` section for our buffer where we will put the reversed string:

```assembly
;; Definition of the .bss section.
section .bss
        ;; Output buffer where the reversed string will be stored.
        OUTPUT  resb 1
```

After we defined the data needed to build our program, we can define the `.text` section:

```assembly
;; Definition of the .text section.
section .text
        ;; Reference to the entry point of our program.
        global  _start

;; Entry point of the program.
_start:
        ;; Set the rcx value to 0. It will be used as a storage for the input string length.
        xor rcx, rcx
        ;; Store the address of the input string in the rsi register.
        mov rsi, INPUT
        ;; Store the address of the output buffer in the rdi register.
        mov  rdi, OUTPUT
        ;; Call the reverseStringAndPrint procedure.
        call reverseStringAndPrint
```

At the beginning of our program, we need to:

- Set the value of the `rcx` register to `0`. We will use this register to store the length of the input string that we need to reverse.
- Point the `rsi` register to the input string.
- Point the `rdi` register to the output buffer that will store the reversed string.

After that, we need to call the `reverseStringAndPrint` procedure to calculate the length of the input string and reverse it. Let's take a look at the implementation of this procedure:

```assembly
;; Calculate the length of the input string and prepare to reverse it.
reverseStringAndPrint:
        ;; Compare the first element in the given string with the NUL terminator (end of the string).
        cmp byte [rsi], 0
        ;; If we reached the end of the input string, reverse it.
        je reverseString
        ;; Load byte from the rsi to al register and move pointer to the next character in the string.
        lodsb
        ;; Save the character of the input string on the stack.
        push rax
        ;; Increase the counter that stores the length of our input string.
        inc rcx
        ;; Continue to go over the input string if we did not reach its end.
        jmp reverseStringAndPrint
```

At the beginning of this procedure, we compare the value pointed to by the `rsi` register with `0`. Here, `0` means the end of the input string, as each string is [NUL-terminated](https://en.wikipedia.org/wiki/Null-terminated_string). If we reach the end of the input string, we jump to the `reverseString` label, which will reverse our string. Otherwise, we take characters one by one from the input string using the `loadsb` instruction and store them on the stack. It is very convenient to store the string's characters on the stack. Since the stack has a [LIFO](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) access pattern, we will pop the characters from the stack in reverse order — from the end to the beginning. This allows us to reverse the string. This procedure is [recursive](https://en.wikipedia.org/wiki/Recursion) and will be called repeatedly until we reach the end of the string.

After reaching the end of the string, we can reverse it. We will do it using the following code:

```assembly
;; Reverse the string and store it in the output buffer.
reverseString:
        ;; Check the counter that stores the length of the string.
        cmp rcx, 0
        ;; If it is equal to `0`, print the reverse string.
        je printResult
        ;; Pop the character from the stack.
        pop rax
        ;; Put the character to the output buffer.
        mov [rdi], rax
        ;; Move the pointer to the next character in the output buffer.
        inc rdi
        ;; Decrease the counter of the length of the string.
        dec rcx
        ;; Move to the next character until we reach the end of the string.
        jmp reverseString
```

In the first two lines of the code, we check the counter that stores the length of our string. If it is equal to `0`, the string reversal is finished, and we can push it with the `printResult` procedure. Otherwise, we pop the character from the stack to the `rax` register and put it to the address pointed by the `rdi` register. During these operations, we call two additional `inc` and `dec` instructions to:

- Decrease the counter that stores the length of the string to exit from the procedure when we reach the end of the string.
- Increment the address stored in the `rdi` register to point to the next free space in the output buffer for the next character.

At the end of executing `reverseString`, we should have a reversed string in the output buffer. It's time to print it and exit our program with:

```assembly
;; Print the reversed string to the standard output.
printResult:
        ;; Set the length of the result string to print.
        mov rdx, rdi
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the result string to print.
        mov rsi, OUTPUT
        ;; Call the `sys_write` system call.
        syscall

        ;; Set the length of the result string to print.
        mov rdx, NEW_LINE_LEN
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the result string to print.
        mov rsi, NEW_LINE
        ;; Call the `sys_write` system call.
        syscall

        ;; Specify the number of the system call (60 is `sys_exit`).
        mov rax, SYS_EXIT
        ;; Set the first argument of `sys_exit` to 0. The 0 status code is a success.
        mov rdi, EXIT_CODE
        ;; Call the `sys_exit` system call.
        syscall
```

If you carefully read the previous chapters, the code above needs no explanation. At this point, our program is ready, and we can build it as usual:

```bash
$ nasm -g -f elf64 -o reverse.o reverse.asm
$ ld -o reverse reverse.o
```

Then, try to run it:

```bash
$ ./reverse
!dlrow olleH
```

Works as expected! 🎉🎉🎉

## Conclusion

In this chapter, we got familiar with more assembly instructions, which means that you can already write more or less advanced programs using assembly programming language. Good job! 🥳

For more information about different instructions for `x86_64`, go to the [Intel manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).
