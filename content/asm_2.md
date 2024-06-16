# The `x86_64` concepts

Some days ago I wrote the first blog post - [Introduction to x86_64 assembly](https://github.com/0xAX/asm/blob/master/content/asm_1.md) which to my surprise caused great interest:

![newscombinator](./assets/newscombinator-screenshot.png)
![reddit](./assets/reddit-screenshot.png)

It motivated me even more to describe my way of learning assembly programming for Linux x86_64. During these days I got the great feedback from the different people around internet. There were many grateful words, but what is more important to me, there were many advice and much of adequate and very useful critics. Especially I want to say thank you words for the great feedback to:

- [Fiennes](https://reddit.com/user/Fiennes)
- [Grienders](https://disqus.com/by/Universal178/)
- [nkurz](https://news.ycombinator.com/user?id=nkurz)

Despite these people I want to say thank you to all who took a part in the discussion on [reddit](https://www.reddit.com/r/programming/comments/2exmpu/say_hello_to_assembly_part_1_linux_x8464/). There were many different opinions, that first part was a not very clear for an absolute beginner. That is why I decided to write more informative posts. So, let's start with the second part of learning assembly programming.

## Terminology and Concepts

As I wrote above, I got many comments from the different people that some parts of first post are not clear. Despite I tried to rework the first part to make some things more clear, the main goal of it was just an introduction without diving very deep. We got our first assembly program that we can run on our computers. Now it is time to start with the basics. Let's start from the description of some terminology that we will see and use in this and in the next parts.

### Processor register

One of the first concept that we have met in the previous part was - `register`. In the previous chapter we agreed that we can consider a `register` as a small memory slot. If we'll read the definition at [wikipedia](A processor register is a quickly accessible location available to a computer's processor), we will see that it is not so far from the reality:

> A processor register is a quickly accessible location available to a computer's processor

The main goal of a processor is data processing. To process data, a process should be able to access this data somewhere. Of course, a processor can get data from [RAM](https://en.wikipedia.org/wiki/Random-access_memory), but it is slow operation. If we will take a look at the [Latency Numbers Every Programmer Should Know](https://samwho.dev/numbers), we will see the following picture:

> L1 cache reference = 1ns
> ...
> Main memory reference = 100ns

Access to the [L1 cache](https://en.wikipedia.org/wiki/CPU_cache) is `100x` times faster than access to the main memory. The processor registers are 'closer' to the processor. For example you can take a look at the list of latencies for different instructions by [Agner Fog](https://www.agner.org/optimize/#manual_instr_tab).

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
- Bounds registers
- Memory management registers

The details description of any registers you can find in the [Intel software developer manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html). For this moment we will stop only at the description of the general purpose registers as in most of our examples we will use only them. If we will use other types of registers, this will be mentioned in the respective example. We already have seen the set of the general purpose registers in the previous [chapter](https://github.com/0xAX/asm/blob/master/content/asm_1.md):

![registers](/content/assets/registers.png)

We have `16` registers with size of 64 bits, from `rax` to `r15`. Some parts of each `64-bit` register has own name. For example, as we may see in the table above, the lower `32-bits` of the `rax` register is called `eax`. In the same way, the lower `16 bits` of the `eax` register is called `ax`. In the end, the lower `8 bits` if the `ax` register is called `al` and the higher `8 bits` is called `ah`. Schematically we can look at this as:

![rax](/content/assets/rax.svg)

As we may understand, based on the name - `general purpose registers`, the two main purposes of these registers are:

- address memory
- perform basic arithmetic

Besides this, some registers are reserved for calling the [system calls](#system-call).

### Endianness

A computer operates with bytes. The bytes could be stored in memory in different order. This order in which a computer stores a sequence of bytes called - `endianness`. There are two types of endianness:

- big
- little

We can imagine memory as one large array of bytes. Each byte has own address. Each address stores one element of the memory array. For example let's consider we have following four bytes in memory: `AA 56 AB FF`. In the `little-endian` order the least significant byte has the smallest address:

| Address            | Byte |
|--------------------|------|
| 0x0000000000000000 | 0xFF |
| 0x0000000000000001 | 0xAB |
| 0x0000000000000002 | 0x56 |
| 0x0000000000000003 | 0xAA |

In a case of the big-endian order, the bytes are stored in the opposite order to the `little-endian`. So if will consider the same set of bytes - `AA 56 AB FF`, it will be:

| Address            | Byte |
|--------------------|------|
| 0x0000000000000000 | 0xAA |
| 0x0000000000000001 | 0x56 |
| 0x0000000000000002 | 0xAB |
| 0x0000000000000003 | 0xFF |

### System call

A [system call](https://en.wikipedia.org/wiki/System_call) - is an operating system API. A user level program can use this API to achieve different functionality that an operating system kernel can execute. As it was mention in the previous [chapter](https://github.com/0xAX/asm/blob/master/content/asm_1.md), you can find all the system calls of the Linux kernel for the `x86_64` architecture [here]((https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl)).

Usually, a system call is a [C](https://en.wikipedia.org/wiki/C_(programming_language)) function. To call such a function, we need to prepare parameters of this function. As we have seen in the previous part, some general purpose registers were used for this goal. How functions are called and how the function parameters are passed is called - `calling conventions`. For the Linux `x86_64`, the calling conventions are specified in the [System V Application Binary Interface](https://en.wikipedia.org/wiki/Application_binary_interface) document. Let's take a closer look how arguments are passed. The first six parameters are passed in the general purpose registers - `rdi`, `rsi`, `rdx`, `r10`, `r8` and `r9`. If we are using user-level wrapper instead of calling a system call directly, the order of registers/parameters will be different. For this moment, let's focus only on the calling conventions of the system calls. The number of a system call is passed in the `rax` register. After all the parameters are prepared, the system call is called with the instruction `syscall`. After the system call is finished to work, the result is returned in the `rax` register.

### Stack

We can not dive into assembly programming without knowing one of the crucial concept of the `x86_64` (and not only) architecture - the stack. The stack is a storage mechanism. Usually a process has a very restricted count of registers. As we already know, an `x86_64` processor gives us access to the `16` general purpose registers. This number is very limited. We may need more or even much more. In this case we can use the stack. Basically we can look at the stack as at the usual concept of memory, but with the single significant difference - the access pattern. With the usual [RAM](https://en.wikipedia.org/wiki/Random-access_memory) model we can access any byte of the memory which is accessible to our user-level application. The stack is accessed as [last in, first our](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) pattern. There are two special instructions that are used to push a value on the stack and pop a value from it:

- `push`
- `pop`

The stack grows downwards from high addresses to low. So, basically when we hear `top of the stack`, it means the lowest address. The general purpose registers `rsp` always should point to the top of the stack. In the [system call](#system-call) section, we have seen that first six arguments of a system call are passed in the general purpose registers. But what if a function has more than six arguments? In a case of system call - according to the `ABI` it is forbidden. In a case of usual functions, the first six parameters are also passed in the general purpose registers and the all the next parameters are passed on the stack.

Let's take a look at the assembly variant of the a bit artificial functions:

```C
int foo(int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7, int arg8) {
    return arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7 + arg8;
}

int bar() {
    return foo(1, 2, 3, 4, 5, 6, 7, 8);
}
```

We will see the following assembly code:

```assembly
bar:
        push    rbp
        mov     rbp, rsp
        push    8
        push    7
        mov     r9d, 6
        mov     r8d, 5
        mov     ecx, 4
        mov     edx, 3
        mov     esi, 2
        mov     edi, 1
        call    foo
```

> [!NOTE]
> The C program should be compiled without any optimization flags.

We may see that the eighth and seventh parameters of the `foo` function are pushed on the stack with the `push` instructions and the first sixth parameters are passed in the general purpose registers.

In the example above, besides the preparation of the `foo` function arguments and calling the function itself, we may see two additional instructions:

```assembly
push    rbp
mov     rbp, rsp
```

The general purpose register `rbp` is the so-called `frame pointer`. The `rbp` register is also called `base pointer`. Each function has a `stack frame` - is a memory area where function is stored [local variables](https://en.wikipedia.org/wiki/Local_variable) and other data. The `rsp` register is always points to the `top` of the stack. In the beginning of each function the current value of the `rbp` is preserved on the stack and value of the top of the stack is moved to the `rbp`. At the next steps a function may use offset (both positive and negative) from the value of the `rbp` to to store and access the function parameters and local variables.  Let's try to understand this concept as it is very important.

Let's take a look at the assembly code of the `bar` and the `foo` functions:

```assembly
bar:
        push    rbp
        mov     rbp, rsp
        push    8
        push    7
        ...
        ...
        ...
        call    foo

foo:
        push    rbp
        mov     rbp, rsp
        mov     DWORD PTR [rbp-4], edi
        mov     DWORD PTR [rbp-8], esi
        mov     DWORD PTR [rbp-12], edx
        mov     DWORD PTR [rbp-16], ecx
        mov     DWORD PTR [rbp-20], r8d
        mov     DWORD PTR [rbp-24], r9d
        ...
        ...
        ...
        pop     rbp
        ret
```

Starting from the `bar` function we may see the following operations on the stack:

- Save the current value of the `rbp` on the stack and move the address of the current top of the stack to `rbp`.
- Push eighths argument on the stack.
- Push seventh argument on the stack.
- Call the function - `foo`. The `call` instruction will store on the stack the address where we should return from the `foo`.
- Save the current value of the `rbp` on the stack and move the address of the current top of the stack to `rbp`.
- Move the value stored in the `edi` register (the first argument of the `foo` function) to the `-4` (the offset is negative because you should remember that stack grows down) bytes offset from frame pointer.
- Move the value stored in the `esi` register (the second argument of the `foo` function) to the `-8` bytes offset from frame pointer.
- ...

So after the last `mov` instruction in the function `foo`, our stack will look like:

![stack](/content/assets/stack.svg)

In the end of the `foo` function, we remove `rbp` from the stack. The last `ret` instruction pops the return address from the stack and then continue execution from this address.

### Program sections

As we have seen in the first post, an each program consists from program sections (or segments). Each executable file on Linux x86_64 is represented in [ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) format. Each elf file has table of sections that is a program consists from. We may see the list of sections of our `hello` program from the previous post using the [readelf](https://man7.org/linux/man-pages/man1/readelf.1.html) utility:

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

As we may see, there are four sections. Two of them we added by ourselves during writing the assembly code. The additional two sections added by the compiler. Technically we can define any section in our program. But there are well known sections:

-  `data` - section is used for declaring initialized data or constants.
-  `bss` - section is used for declaring non initialized variables.
-  `text` - section is used for code of the program.

### Data Types

Obviously assembly is not a [statically typed programming language](https://en.wikipedia.org/wiki/Category:Statically_typed_programming_languages). Usually we operate with set of bytes. Despite this, [NASM](https://nasm.us/) gives us some helpers at least to define the size of data that we are operating. The fundamental data types are:

- byte
- word
- doubleword
- quadword
- double quadword.

A byte is eight bits, a word is `2` bytes, a doubleword is `4` bytes, a `quadword` is `8` bytes and a double quadword is `16` bytes. In the section above, we already have seen an example:

```assembly
;; move 4 bytes value from the edi register to the RBP - 4 bytes offset
mov     DWORD PTR [rbp-4], edi
```

NASM provides pseudo-instructions to help us to define data with the given size - `DB`, `DW`, `DD`, `DQ`, `DT`, `DO`, `DY` and `DZ`. The pseudo-instructions from `DB` to `DQ` are used to define data with the size from byte to double quadword. The `DT` is used to define `10` bytes. The `DO` is used to define `16` bytes. The `DY` is used to define `32` bytes. The `DZ` is used to define `64` bytes. In addition there are alternatives to define uninitialized storage - `RESB`, `RESW`, `RESD`, `RESQ`, `REST`, `RESO`, `RESY` and `RESZ`.

For example:

```assembly
section .data
    ;; Define byte with the value 100
    num1   db 100
    ;; Define 2 bytes with the value 1024
    num2   dw 1024
    ;; Define set of characters (10 is ASCII \n)
    msg    db "Sum is correct", 10
```

If we will access a constant, that is defined in this way we will get the address of it but not the actual value. If we want to get the actual value that is located by the given address we need to specify the constant name in square brackets:

```
;; Move the value of the num1 to the al register
mov al, [num1]
```

Most of the time we are working with numbers. There two types of integer numbers:

- unsigned
- signed

The obvious difference between these two types of numbers is that first can not accept negative numbers. Negative numbers represented with the [Two's complement](https://en.wikipedia.org/wiki/Two%27s_complement) method. In the next posts we will see how floating point numbers are represented.

## Example

After we went thought the most important concepts, it is time to return to the most interesting part - writing the code. Let's take a look at our second simple assembly program. The program will take two integer numbers, get the sum of these numbers and compare it with the third predefined number. If the predefined number is equal to sum, the program will print something on the screen, if not - the program will just exit.

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

Now let's take a look at the our first [control flow](https://en.wikipedia.org/wiki/Control_flow) instructions. Usually programming languages have ability to change order of evaluation (for example with `if` or `case` statements, goto and so on). Assembly programming language also provides very basic ability to change the flow of our programs. The first such instruction is `cmp`. This instruction takes two values and performs comparison between them. Usually it is used along with the conditional jump instruction. For example:

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

Often the unconditional jumps are used to simulate a loop. For example we have label and some code after it. This code executes anything, than we have condition and jump to the start of this code if condition is not successfully. The Loops will be covered in next parts.

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
    ;; Set the value of the num1 to the rax
    mov rax, [num1]
    ;; Set the value of the num2 to the rbx
    mov rbx, [num2]
    ;; Get sum of the rax and rbx. The result is stored in the rax.
    add rax, rbx
.compare:
    ;; Compare the value of the rax with `150`
    cmp rax, 150
    ;; Go to the .exit label if the values of the rax and 150 are not equal
    jne .exit
    ;; Go to the .correctSum label if the values of the rax and 150 are equal
    jmp .correctSum

; Print message that the sum is correct
.correctSum:
    ;; Number of the sytem call. 1 - `sys_write`.
    mov rax, 1
    ;; The first argument of the `sys_write` system call. 1 is `stdout`.
    mov rdi, 1
    ;; The second argument of the `sys_write` system call. Reference to the message.
    mov rsi, msg
    ;; The third argument of the `sys_write` system call. Length of the message.
    mov rdx, 20
    ;; Call the `sys_write` system call.
    syscall
    ; Go to the exit of the program.
    jmp .exit

; exit procedure
.exit:
    ;; Number of the system call. 60 - `sys_exit`.
    mov rax, 60
    ;; The first argument of the `sys_exit` system call.
    mov rdi, 0
    ;; Call the `sys_exit` system call.
    syscall
```

First of all let's try to build, run our program and see the result. We can build our program in the similar way that we saw in the previous part:

```bash
$ nasm -f elf64 -o program.o program.asm
$ ld -o program program.o
```

After we built our program, we can run it with:

```bash
~$ ./program
Sum is correct
```

Now let's go through the source code of our program. First of all there is the `.data` section with three constants:

- `num1`
- `num2`
- `msg`

The entry point of our program is the `_start` symbol. In the beginning of the source code of our program we transfer the values of the `num1` and `num2` to the general purpose registers `rax` and `rbx`. After this we can use the `add` instruction to get the sum of these two values. The result of the sum will be stored in the `rax` register. We got the sum of two our numeric values. According to the description of our program, now we must compare it with the predefined number. We do it with the `cmp` instruction. At this point we have two ways to go. The first one - we jump to the `.exit` label if the value of the `rax` (that stores sum of the `num1` and `num2` values) is not equal to `150`. If the sum is equal to `150`, we jump to the `.correctSum` label.

The source code of the both `.correctSum` and `.exit` sub-routines should be familiar to us. They both do very similar what we already have seen in the previous chapter. The `.correctSum` sub-routine prints the string from the `msg` to the screen. The `.exit` sub-routine provides us graceful exit from our program.

That is it for this post. In the next post we will continue to dive into assembly programming.
