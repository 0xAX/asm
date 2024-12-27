# The `x86_64` concepts

Some days ago I wrote the first post about [Introduction to assembly](https://github.com/0xAX/asm/blob/master/content/asm_1.md) which, to my surprise, caused great interest:

![newscombinator](./assets/newscombinator-screenshot.png)
![reddit](./assets/reddit-screenshot.png)

It motivated me to continue describing my journey through learning assembly programming for Linux x86_64. During these days I got great feedback from people all over the Internet. There were many words of gratitude, but, what is more important to me, there was also much adequate advice and very useful criticism. Especially, I want to say thank you for the great feedback to:

- [Fiennes](https://reddit.com/user/Fiennes)
- [Grienders](https://disqus.com/by/Universal178/)
- [nkurz](https://news.ycombinator.com/user?id=nkurz)

I also want to say thank you to all who took part in the discussion on [reddit](https://www.reddit.com/r/programming/comments/2exmpu/say_hello_to_assembly_part_1_linux_x8464/). There were many different opinions, some of them saying that the first post was not so clear for an absolute beginner. These comments inspired me to rework the first post and make some things more clear, keeping in mind that the main goal was just an introduction without diving too deep. For the future, I will try my best to write more informative posts.

So, let's start with the second part of learning assembly programming where I will try to bring closer the basic `x86_64` concepts.

## Terminology and concepts

Now that we've successfully written and run our first assembly program, it's time to learn the basics. Let's start with some terminology and concepts that we will see and use from now on.

### Processor registers

One of the first concepts we met in the previous post was a **register**. We agreed that we can consider a register as a small memory slot. Following the definition on [Wikipedia](https://en.wikipedia.org/wiki/Processor_register), we can see that it's not so far from truth:

> A processor register is a quickly accessible location available to a computer's processor.

The main goal of a processor is data processing. To process data, a processor must access this data somewhere. Of course, a processor can get data from [main memory](https://en.wikipedia.org/wiki/Random-access_memory), but it is a very slow operation. If we take a look at the [Latency Numbers Every Programmer Should Know](https://samwho.dev/numbers), we can see the following picture:

```
L1 cache reference = 1ns
...
...
...
Main memory reference = 100ns
```

Access to the [L1 CPU cache](https://en.wikipedia.org/wiki/CPU_cache) is `100x` times faster than access to the main memory. The processor registers are even "closer" to the processor. For comparison, you can take a look at the list of latencies for different instructions by [Agner Fog](https://www.agner.org/optimize/#manual_instr_tab).

There are different types of registers on the `x86_64` processors:

- General purpose registers
- Segment registers
- RFLAGS registers
- Control registers
- Model-specific registers
- Debug registers
- x87 FPU registers
- MMX registers
- XMM registers
- YMM registers
- ZMM registers
- Bounds registers
- Memory management registers

You can find a detailed description of registers in the [Intel software developer manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html). For now, we will focus only on the **general purpose registers** as we will use them in most examples. If we will use other registers, I will mention it beforehand. We already saw a table with general purpose registers in the [previous chapter](https://github.com/0xAX/asm/blob/master/content/asm_1.md#cpu-registers-and-system-calls):

![registers](/content/assets/registers.png)

There are 16 registers of 64 bits size, from `rax` to `r15`. Each register also has smaller parts with their own names. For example, as we may see in the table above, the lower 32 bits of the `rax` register are called `eax`. Similarly, the lower 16 bits of the `eax` register are called `ax`. Finally, the lower 8 bits of the `ax` register are called `al`, while the higher 8 bits are called `ah`. We can visualize this as:

![rax](/content/assets/rax.svg)

The general purpose registers are used in many different cases, like performing arithmetic and logical operations, transferring data, memory address calculation operations, passing parameters to functions and system calls, and many more. When going through these chapters, we will see how to use the general purpose registers to perform different operations.

### Endianness

A computer operates with bytes of data. The bytes can be stored in memory in different order. The order in which a computer stores a sequence of bytes is called **endianness**. There are two types of endianness:

- `big`
- `little`

We can imagine memory as one large array of bytes, where each byte has its own unique address. For example, let's say we have the following four bytes in memory: `AA 56 AB FF`. In the `little-endian` order, the least significant byte is stored at the smallest memory address:

| Address            | Byte |
|--------------------|------|
| 0x0000000000000000 | 0xFF |
| 0x0000000000000001 | 0xAB |
| 0x0000000000000002 | 0x56 |
| 0x0000000000000003 | 0xAA |

In the case of the `big-endian` order, the bytes are stored in the opposite order, so the most significant byte is stored at the smallest memory address:

| Address            | Byte |
|--------------------|------|
| 0x0000000000000000 | 0xAA |
| 0x0000000000000001 | 0x56 |
| 0x0000000000000002 | 0xAB |
| 0x0000000000000003 | 0xFF |

### System calls

A [system call](https://en.wikipedia.org/wiki/System_call) is a set of APIs provided by an operating system. A user-level program can use these APIs to achieve different functionalities that an operating system kernel provides. As mentioned in the previous [chapter](https://github.com/0xAX/asm/blob/master/content/asm_1.md#cpu-registers-and-system-calls), you can find all the system calls of the Linux kernel for the `x86_64` architecture [here](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl).

There are two ways to execute a system call:

- Using a library function like [printf](https://man7.org/linux/man-pages/man3/fprintf.3.html), which internally calls the OS-level API 
- Making a system call directly using the `syscall` instruction

To call a system call directly, we must prepare the parameters of this function. As we saw in the previous post, some general purpose registers were used for that. The rules that define how the system calls and functions are called and how their parameters are passed are called **calling conventions**. For the Linux `x86_64`, the calling conventions are specified in the [System V Application Binary Interface](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf) PDF document.

Let's take a closer look at how arguments are passed to a system call if we trigger a system call using the `syscall` instruction.

The first six parameters are passed in the following general purpose registers:

- `rdi` - used to pass the first argument to a function.
- `rsi` - used to pass the second argument to a function.
- `rdx` - used to pass the third argument to a function.
- `r10` - used to pass the fourth argument to a function.
- `r8` - used to pass the fifth argument to a function.
- `r9` - used to pass the sixth argument to a function.

If we use a user-level wrapper instead of calling a system call directly, the order of registers and parameters will be different. For now, let's focus only on the calling conventions of the system calls using the Linux kernel interface. The system call number is passed in the `rax` register. Once we set up all the parameters in their respective registers, we can call the system call with the instruction `syscall`. After the system call is finished, the result is returned in the `rax` register.

### Program sections

As we saw in the first post, each program consists of program sections (or segments). Each executable file on Linux x86_64 is represented in the [ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) format. An ELF file has a table of sections that a program consists of. We can see a list of sections in our `hello` program from the previous post using the [readelf](https://man7.org/linux/man-pages/man1/readelf.1.html) utility:

```
~$ strip hello && readelf -S hello

There are 4 section headers, starting at offset 0x2028:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000401000  00001000
       0000000000000027  0000000000000000  AX       0     0     16
  [ 2] .data             PROGBITS         0000000000402000  00002000
       000000000000000d  0000000000000000  WA       0     0     4
  [ 3] .shstrtab         STRTAB           0000000000000000  0000200d
       0000000000000017  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), l (large), p (processor specific)
```

As we can see, there are four sections. Two of them (`text` and `data`) were defined by us while writing the assembly code. The remaining two sections were added automatically by the compiler. While we can technically define any section in our program, there are some well-known, commonly used sections:

- `data` - used for declaring initialized data or constants.
- `bss` - used for declaring non-initialized variables.
- `text` - used for the code of the program.
- `shstrtab` - stores references to the existing sections.

### Data types

Assembly is not a [statically typed programming language](https://en.wikipedia.org/wiki/Category:Statically_typed_programming_languages). Usually, we work directly with a raw set of bytes. However, [NASM](https://nasm.us/) provides us with some helpers to define the size of data we are operating. The fundamental data types are:

- `byte` - 8 bits
- `word` - 2 bytes
- `doubleword` - 4 bytes
- `quadword` - 8 bytes

A byte is eight bits, a word is two bytes, a doubleword is four bytes, and a quadword is eight bytes. NASM provides pseudo-instructions to help us define the size:

- `DB` - `byte` - 8 bits
- `DW` - `word` - 2 bytes
- `DD` - `doubleword` - 4 bytes
- `DQ` - `quadword` - 8 bytes
- `DT` - 10 bytes
- `DO` - 16 bytes
- `DY` - 32 bytes
- `DZ` - 64 bytes

The pseudo-instructions from `DB` to `DQ` are used to define data with the size from `byte` to `quadword`. Additionally, `DT` is used to define 10 bytes, `DO` is used to define 16 bytes, `DY` is used to define 32 bytes, and `DZ` is used to define 64 bytes. 

For example:

```assembly
section .data
    ;; Define a byte with the value 100
    num1   db 100
    ;; Define 2 bytes with the value 1024
    num2   dw 1024
    ;; Define a set of characters (10 is a new line symbol in ASCII \n)
    msg    db "Sum is correct", 10
```

There are also alternatives to define uninitialized storage - `RESB`, `RESW`, `RESD`, `RESQ`, `REST`, `RESO`, `RESY`, and `RESZ`. These are used similarly to `DB` - `DZ`, but in this case, we do not provide an initial value for the defined variable.

For example:

```assembly
section .bss
    ;; Define a buffer with the size 64 bytes
    buffer resb 64
```

After defining variables, we can start using them in our program's code. To use a variable, we can refer it by name. However, there is a small thing to remember in the NASM assembly syntax: accessing a variable by name gets us its address, not the actual value it stores:

```assembly
;; Move the address of the `num1` variable to the al register
move al, num1
```

To get the actual value that located in the given address, we need to specify the variable name in square brackets:

```assembly
;; Move the value of num1 to the al register
mov al, [num1]
```

### Stack

We can not dive into assembly programming without knowing one of the crucial concept of the `x86_64` (and not only) architecture - the stack. The stack is a memory area of a program that is accessed in a [last in, first out](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) pattern.

A processor has a very restricted count of registers. As we already know, an `x86_64` processor gives us access to the `16` general purpose registers. This number is very limited. We may need more or even much more space to store our data. The one of the way to solve this issue is using the program's stack. Basically we can look at the stack as at the usual concept of memory area, but with the single significant difference - the access pattern. With the usual [RAM](https://en.wikipedia.org/wiki/Random-access_memory) model we can access any byte of the memory which is accessible to our user-level application. The stack is accessed as [last in, first out](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) pattern. There are two special instructions that are used to push a value on the stack and pop a value from it:

- `push` - push the operand on the stack.
- `pop` - pop the top value from the stack.

The stack grows downwards from the high addresses to low. So, basically when we hear `top of the stack`, it means the lowest address. The general purpose registers `rsp` always should point to the top of the stack. In the [system call](#system-call) section, we have seen that first six arguments of a system call are passed in the general purpose registers. According to the calling conventions document:

> System-calls are limited to six arguments, no argument is passed directly on the stack.

So the available number of the general purpose registers should be enough to execute any system call. But what about other functions? What if one has more than six arguments? In this case the first six parameters are also passed in the general purpose registers and the all the next parameters are passed on the stack. The set of the general purpose registers to call a library function is slightly different from the set of registers used for a system call:

- `rdi` - used to pass the first argument to a function.
- `rsi` - used to pass the second argument to a function.
- `rdx` - used to pass the third argument to a function.
- `rcx` - used to pass the fourth argument to a function.
- `r8` - used to pass the fifth argument to a function.
- `r9` - used to pass the sixth argument to a function.

Let's take a look at the assembly code of the a bit artificial functions written in C programming language:

```C
int foo(int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7, int arg8) {
    return arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7 + arg8;
}

int bar() {
    return foo(1, 2, 3, 4, 5, 6, 7, 8);
}
```

If we will compile it and have a look at the assembly code, we will see something like that:

```assembly
bar:
        ;; Preserve the base pointer
        push    rbp
        ;; Preserve the stack pointer
        mov     rbp, rsp
        ;; Push the eight argument on the stack
        push    8
        ;; Push the seventh argument on the stack
        push    7
        ;; Push the sixth argument on the stack
        mov     r9d, 6
        ;; Push the fifth argument on the stack
        mov     r8d, 5
        ;; Push the fourth argument on the stack
        mov     ecx, 4
        ;; Push the third argument on the stack
        mov     edx, 3
        ;; Push the second argument on the stack
        mov     esi, 2
        ;; Push the first argument on the stack
        mov     edi, 1
        ;; Call the function `foo`
        call    foo
        ;; Clean-up the stack from the 8th and 7th arguments
        add     rsp, 16
        ;; Restore the old rbp
        leave
        ;; Return from the function
        ret
foo:
        ;; Preserve the base pointer
        push    rbp
        ;; Preserve the stack pointer
        mov     rbp, rsp
        ;; Move 4 bytes value from the edi register to the address stored in the rbp register minus 4 bytes offset
        mov     DWORD PTR [rbp-4], edi
        ;; Move 4 bytes value from the esi register to the address stored in the rbp register minus 8 bytes offset
        mov     DWORD PTR [rbp-8], esi
        ;; Move 4 bytes value from the edx register to the address stored in the rbp register minus 12 bytes offset
        mov     DWORD PTR [rbp-12], edx
        ;; Move 4 bytes value from the ecx register to the address stored in the rbp register minus 16 bytes offset
        mov     DWORD PTR [rbp-16], ecx
        ;; Move 4 bytes value from the r8d register to the address stored in the rbp register minus 20 bytes offset
        mov     DWORD PTR [rbp-20], r8d
        ;; Move 4 bytes value from the r9d register to the address stored in the rbp register minus 24 bytes offset
        mov     DWORD PTR [rbp-24], r9d
        ...
        ... # skip arithmetic operations for now
        ...
        ;; Restore the old rbp
        pop     rbp
        ;; Return from the function
        ret
```

> [!NOTE]
> The C program should be compiled without any optimization flags. You can use `-O0 -masm=intel` flags for compiler to avoid optimization. You can use tools like [godbolt](https://godbolt.org/) to see the assembly output of these functions.

First of all let's take a look at the first two lines of code in the function `bar`:

```assembly
push    rbp
mov     rbp, rsp
```

The names of these two instructions in the beginning of each function is - [function prologue](https://en.wikipedia.org/wiki/Function_prologue_and_epilogue#Prologue). Each function usually operates with a part of the stack. Such part is called a [stack frame](https://en.wikipedia.org/wiki/Call_stack). To manage stack CPU is using the several general purpose registers:

- `rip`
- `rsp`
- `rbp`

The general purpose register `rip` is the so-called `instruction pointer`. This register store the address of the next instruction CPU is going to execute. When CPU meets the `call` instruction in order to call a function, it pushes the address of the next instruction after the function call to the stack. This is done in order to know where to return from the called function.

The `rsp` register is always points to the `top` of the stack and called - `stack pointer`. After we push something on the stack using the `push` instruction, the stack pointer address is decreased. After we pop something from the stack using the `pop` instruction, the stack pointer address is increased.

The general purpose register `rbp` is the so-called `frame pointer` or `base pointer`. As we mentioned above, each function has own `stack frame` - is a memory area where function stores [local variables](https://en.wikipedia.org/wiki/Local_variable) and other data.

Now as we know the rough meaning of the stack frame term and the usage of the `rbp`, `rsp` and `rip` registers let's try to understand what happens when we call a function. Let's take a look at the stack right before the `call foo` is executed. Our stack looks like this:

![stack-before-call](./assets/stack-before-call.svg)

After the execution of the `call` instruction, the return address (or address of the next instruction) is pushed to the stack. So our stack layout will look like this:

![stack-during-call](./assets/stack-during-call.svg)

Right in the beginning of the new function we have to preserve `rbp` value pushing it onto the stack. At this time the `rbp` register contains base pointer of the previous function or in other words we may say that the value of the `rbp` in the beginning of each function represents the address of the bottom (or the base) of the stack of the caller. Since we are in the new function - it needs a new stack frame and as a result the new base. After this point we have the following stack layout:

![stack-preserve-bp](./assets/stack-preserve-bp.svg)

The next step is to put the value of the current stack pointer in the `rbp`. Starting from this point we have new stack frame for our function `foo`. Since the stack frame is ready we can start to manage function parameters and local variables.

The first sixth parameters of the `foo` function were passed using the general purpose registers in the function `bar`. We may see that the eighth and seventh parameters of the `foo` function are pushed on the stack with the `push` instructions in the function `bar` as well. Please note that the eight and seventh arguments of the function `foo` are pushed to the stack especially in this order - first pushed the value `8` and only after the `7`. Above we already mentioned that the stack has the access pattern - `last in, first out`. So if we'd use `pop` instruction right after we pushed these both parameters, we'd get at first seventh and after it eighths argument.

To do the calculation we need to access the input parameters. As you may see it is done using the address stored in the `rbp` register and offsets from it. The offsets are negative as you may remember the stack grows down towards lower addresses. At first we move the value stored in the `edi` register (the first argument of the `foo` function) to address stored in the `rbp` register with the `-4` (the offset is negative because you should remember that stack grows down) bytes offset. After that we move the value stored in the `esi` register (the second argument of the `foo` function) to the address stored in the `rbp` register with the `-8` bytes offset. We repeat these operations for the all six input arguments.

Now take a look one more time very carefully:

> to the address stored in the `rbp` register with the `N` byte offset

What was the address stored in the `rbp`? Our stack pointer! So after the last `mov` instruction in the function `foo`, our stack frame will look like this:

![stack](/content/assets/stack.svg)

That is the whole sense of the `rbp`. It plays role of an anchor in the function or a base point. Using the positive offsets we may access the return address and the parameters pushed on the stack by the caller and using the negative offsets we may access local variables.

Right before the return from the `foo` function we may see so called [function epilogue](https://en.wikipedia.org/wiki/Function_prologue_and_epilogue#Epilogue) we restore the initial value of the `rbp` by removing it from the stack. The last `ret` instruction pops the return address from the stack and the execution continues from this address.

## Example

After we went thought the most important concepts, it is time to return to the most interesting part - writing the programs. Let's take a look at our second simple assembly program. The program will take two integer numbers, get the sum of these numbers and compare it with the third predefined number. If the predefined number is equal to sum, the program will print something on the screen, if not - the program will just exit.

Before writing the code we need to know how to execute basic arithmetic expressions and compare the things.

### Basic arithmetic instructions

Here is the list of some assembly instructions to execute arithmetic operations:

- `ADD`  - Addition.
- `SUB`  - Substraction.
- `MUL`  - Unsigned multiplication.
- `IMUL` - Signed multiplication.
- `DIV`  - Unsigned division.
- `IDIV` - Signed division.
- `INC`  - Increment.
- `DEC`  - Decrement.
- `NEG`  - Negate.

All the details related to the instructions listed above will be described in the example.

### Basic control flow

Now let's take a look at the our first [control flow](https://en.wikipedia.org/wiki/Control_flow) instructions. Usually programming languages have ability to change order of evaluation (for example with `if` or `case` statements, `goto` and so on). Assembly programming language also provides the very basic ability to change the flow of our programs. The first such instruction is `cmp`. This instruction takes two values and performs comparison between them. Usually it is used along with the conditional jump instruction. For example:

```assembly
;; compare value of the rax register with 50
cmp rax, 50
```

The `cmp` instruction executes only comparison of its parameters without affecting values of the parameters themselves. To perform any actions after the comparison, there is conditional jump instructions. The list of these instructions:

-  `JE`  - Jump if the values are equal.
-  `JNE` - Jump if the values are not equal.
-  `JZ`  - Jump if the difference between the two values is zero.
-  `JNZ` - Jump if the difference between the two values is not zero.
-  `JG`  - Jump if the first value is greater than the second.
-  `JGE` - Jump if the first is greater or equal to the second.
-  `JA`  - The same that JG, but performs unsigned comparison.
-  `JAE` - The same that JGE, but performs unsigned comparison.

For example if we want translate something like this if/else statement written in C:

```C
if (rax != 50) {
    foo();
} else {
    bar();
}
```

to assembly, it will something like this:

```assembly
;; compare rax with 50
cmp rax, 50
;; jump to the label `.foo` if the value of the `rax` register is not equal to 50
jne .foo
;; jump to the label `.bar` otherwise
jmp .bar
```

In addition we can jump on a label without any conditions with the `jmp` instruction:

```assembly
jmp .label
```

Often the unconditional jumps are used to simulate a loop. For example we have label and some code after it. This code executes anything, than we have condition and jump to the start of this code if condition is not successfully. The loops will be covered in next parts.

### Program example

Since we learned some basic arithmetic and control flow instructions, we can write our example. Before we will take a look at the program source code, I will remind that we are going to write a simple program that will calculate the sum of two integer numbers and if the sum equal to the third predefined number we will print a string. Otherwise just exist.

Here is the source code of our example:

```assembly
;; Definition of the .data section
section .data
    ;; The first number
    num1 dq 0x64
    ;; The second number
    num2 dq 0x32
    ;; The message to print if the sum is correct
    msg  db "The sum is correct!", 10

;; Definition of the .text section
section .text
    ;; Reference to the entry point of our program
    global _start

;; Entry point
_start:
    ;; Set the value of num1 to rax
    mov rax, [num1]
    ;; Set the value of num2 to rbx
    mov rbx, [num2]
    ;; Get the sum of rax and rbx. The result is stored in rax.
    add rax, rbx
.compare:
    ;; Compare the rax value with 150
    cmp rax, 150
    ;; Go to the .exit label if the rax value is not 150
    jne .exit
    ;; Go to the .correctSum label if the rax value is 150
    jmp .correctSum

; Print message that the sum is correct
.correctSum:
    ;; Specify the system call number (1 is `sys_write`).
    mov rax, 1
    ;; Set the first argument of `sys_write` to 1 (`stdout`).
    mov rdi, 1
    ;; Set the second argument of `sys_write` to the reference of the `msg` variable.        
    mov rsi, msg
    ;; Set the third argument to the length of the `msg` variable's value (20 bytes).
    mov rdx, 20
    ;; Call the `sys_write` system call.
    syscall
    ; Go to the exit of the program.
    jmp .exit

; exit procedure
.exit:
    ;; Specify the number of the system call (60 is `sys_exit`).
    mov rax, 60
    ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
    mov rdi, 0
    ;; Call the `sys_exit` system call.
    syscall
```

First of all let's try to build, run our program with the similar commands that we have seen in the previous chapter and see the result:

```bash
$ nasm -f elf64 -o program.o program.asm
$ ld -o program program.o
```

After we built our program, we can run it with:

```bash
~$ ./program
Sum is correct
```

Now let's go through the source code of our program. First of all there is the `.data` section with three variables:

- `num1`
- `num2`
- `msg`

The entry point of our program is the `_start` symbol. In the beginning of the source code of our program we put the values of the `num1` and `num2` to the general purpose registers `rax` and `rbx`. After this we can use the `add` instruction to get the sum of these two values. The result of the sum will be stored in the `rax` register.

According to the description of our program, now we have to compare the sum of two numbers with the predefined number. We do it with the `cmp` instruction. At this point we have two ways to go. The first one - we jump to the `.exit` label if the value of the `rax` (that stores sum of the `num1` and `num2` values) is not equal to `150`. If the sum is equal to `150`, we jump to the `.correctSum` label.

The source code of the both `.correctSum` and `.exit` sub-routines should be familiar to us. They both do very similar what we already have seen in the previous chapter. The `.correctSum` sub-routine prints the string from the `msg` to the screen. The `.exit` sub-routine provides us graceful exit from our program.

That is it for this post. In the next post we will continue to dive into assembly programming.
