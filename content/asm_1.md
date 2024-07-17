# Introduction

Hello! We are welcome you in our short series of posts about [assembly](https://en.wikipedia.org/wiki/Assembly_language) programming language. Most probably you are a software developer as me, who is interested in low-level programming. Despite the fact that neither I, nor most likely you using this programming language on our daily basis - the information that is presented in this set of posts still could be highly useful. Yes, we are using high-level programming languages, libraries and frameworks. In most cases we do not write sorting algorithms or a string reverse functions manually. Each of us can easily write the simplest code like this:

```C
#include <stdio.h>

int main() {
  int x = 10;
  int y = 100;
  printf("x + y = %d\n", x + y);
  return 0;
}
```

Each of us can understand what's this C code does. But... How this code works at low level? What does the compiler do with this code. How does the computer load and execute the resulted program. I think that not all of us can answer on these questions. The answers for all of these questions always interested me. I know I can write a code using a high level programming languages like Rust, Erlang, Go and etc..., but I absolutely do not know how it works at the low level. What's happening with my code after. I knew about assembly from university. I remember that I did some basic exercises using something very old like [turbo assembler](https://en.wikipedia.org/wiki/Turbo_Assembler). I did these exercises without deep understanding of what I am doing, copying pieces of code with other students from each other. Many years gone after I graduated from the university. Many years I am writing code professionally using one or a couple of high-level programming languages, frameworks and so on. But these questions appeared in my head more and more often. So I decided to take a few deep steps down, to assembly, and to describe my learning way about the process.

Despite the pure curiosity questions, our colleagues still using assembly. Here is just a short list of active and modern projects where you may find some assembly code:

- [crypto code in openssl](https://github.com/openssl/openssl/tree/master/crypto/sha/asm)
- [ffmpeg codec library](https://github.com/FFmpeg/FFmpeg/tree/master/libavcodec/x86)
- [linux kernel code](https://github.com/torvalds/linux/blob/master/arch/x86/kernel/head_64.S)
- [Browser engines](https://github.com/mozilla/gecko-dev/tree/master/gfx/cairo/libpixman/src)
- [OpenCV Hardware Acceleration Layer](https://github.com/opencv/opencv/tree/master/modules/core/include/opencv2/core/hal)

So let's start.

## Preparation

We must to prepare before we can start. This series of post describes assembly programming for [x86_64](https://en.wikipedia.org/wiki/X86-64) architecture using [Linux](https://en.wikipedia.org/wiki/Linux) operating system. So you must have a machine with `x86_64` CPU and installed one [Linux distribution](https://en.wikipedia.org/wiki/Linux_distribution). Besides the machine with Linux, we also will need a compiler to compile our assembly code. We mostly will use two compilers to compile C and assembly examples:

- [GNU gcc](https://gcc.gnu.org/)
- [NASM](https://nasm.us/)

We will use these two tools in most of examples. If there will be needed something additional, it will be mentioned in the description to an example. Both `GNU gcc` and `NASM` compilers you can install using a package manager of your Linux distribution. In a case of [Debian](https://www.debian.org/) or [Ubuntu](https://ubuntu.com/), you can use the following command to install compilers:

```bash
sudo apt-get install gcc nasm
```

If you are using rpm based distribution you can install compilers with the following command:

```bash
sudo dnf install gcc nasm
```

If you are using another Linux distribution, please consult documentation of your Linux distribution how to install packages.

The last but not least thing that you may need is a text editor where you will write your assembly code. Here I will not advice you anything as it is highly depends on your own preferences. I personally use [GNU Emacs](https://www.gnu.org/software/emacs/) with [nasm-mode](https://github.com/skeeto/nasm-mode). As I said it is not mandatory, of course you can use your favorite text editor. If you use Emacs as I, you can install `nasm-mode` and configure it with:

```elisp
(load "~/.emacs.d/lisp/nasm.el")

(require 'nasm-mode)
(add-to-list 'auto-mode-alist '("\\.\\(asm\\|s\\|S\\)$" . nasm-mode))
```

After these tools are installed and configured we finally can start.

## Basics of NASM assembly syntax

Here we will not see the full syntax of assembly programming language. We will see just some parts of it very shortly. The main goal of this chapter is to have ability to build and run our very first example without diving too deep into assembly and x86_64 CPU architecture. We will start our journey with our favorite and well known [hello world](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) program.

All the code usually consists from code and comments. The comments starts with the `;` symbol. The code of an assembly program usually divided into sections (also sometimes called memory segments). To implement the `hello world` program we will meet only the two following sections:

-  `data` section
-  `text` section

Each section is used to contain specific data. The `data` section is used to declare static data as for example constants. The data could not be changed in runtime. The size of `data` section also could not be expanded in runtime. The syntax for declaring data section is:

```assembly
section .data
```

The `text` section is used to store the instructions of our program. This section must begin with the declaration `global _start`, which tells the operating system kernel where the program execution should [start](https://en.wikipedia.org/wiki/Entry_point) after the program is loaded. The code snippet below shows an example of the declaration of the `text` section and entry point of a program defined with the `_start` symbol:

```assembly
section .text
global _start

_start:
```

Since we know how to define basic sections of the our first assembly program, we can take a look at the first instructions from which our program will consist. Each NASM assembly source code line contains some combination of the following four fields:

```
[label:] instruction [operands] [; comment]
```

Fields which specified within square brackets are optional. A basic `instruction` consists from the two following parts:

- Name of the instruction
- Operands of the instruction

If you already have experience of one of high-level programming languages, for this moment you can look at it as to a function and parameters. For example let's take a look at the following assembly line. Here we may see the instruction `mov` and the operands that is used by the instruction - `COUNT` and `48`:

```assembly
; Put value 48 in the count variable
mov count, 48
```

Since we know the very basics of the assembly syntax and a structure of a program, let's try to write our first program.

## Hello world

Let's write first program using assembly. Here is the code of it:

```assembly
;; Definition of the `data` section
section .data
    ;; String `msg` constant with the value `hello world!`
    msg db      "hello, world!"

;; Definition of the text section
section .text
    ;; Reference to the entry point of our program
    global _start

;; entry point
_start:
    ;; Number of the system call. 1 - `sys_write`.
    mov     rax, 1
    ;; The first argument of the `sys_write` system call.
    mov     rdi, 1
    ;; The second argument of the `sys_write` system call.
    mov     rsi, msg
    ;; The third argument of the `sys_write` system call.
    mov     rdx, 13
    ;; Call the `sys_write` system call.
    syscall
    ;; Number of the system call. 60 - `sys_exit`.
    mov    rax, 60
    ;; The first argument of the `sys_exit` system call.
    mov    rdi, 0
    ;; Call the `sys_exit` system call.
    syscall
```

Looks quite long in a comparison to our usual well known `hello world` program. Let's try to figure our what is going on here and how it works. 

Take a look first 4 lines of the program. We defined the data section and put there the `msg` constant with the `hello world!` value. Since the constant is defined in the `data` section, it could be used in the code of the program. The next is the declaration of the `text` section and the `_start` entry point of the program. After we will run the program, it will start to execute from the `_start` line.

After the both sections are defined and especially the `text` section, we can move to the actual code of the program. The first four lines of the program starts from the `mov` instruction that we already have seen in the previous section of this post. This instruction expects to get two operands and put value of the second to first. That should be more-less clear, but what is it these `rax`, `rdi` and etc... We can read in the wikipedia:

> A central processing unit (CPU) is the hardware within a computer that carries out the instructions of a computer program by performing the basic arithmetical, logical, and input/output operations of the system.

OK, a CPU performs some operations, arithmetical and etc... That we might know without any knowledge about assembly programming. But where a CPU can get data from to execute these instructions? The first and the most obvious answer will be - from memory. However, reading data from memory and storing data into memory slows down the processor, as it involves complicated processes of sending the data request across the control bus. Thus CPU has own internal memory storage locations called - `registers`. Each `x86_64` CPU has the following so called `general purpose registers`

![registers](/content/assets/registers.png)

Each register could be considered as a very small memory slot which may store a value with a size specified in the table above. For example, the `rax` register may contain a value up to `64` bits, the `ax` register may contain a value up to `16` bits and so on. So when we see `mov rax, 1`, this means to put `1` to the `rax` register. Now we have an approximate understanding of what is these `rax`, `rdi`, `rbx` and etc... In the next posts we will find more information about them, for now it is enough to consider them just a small memory slots that a CPU can access in a very fast way. As described above, the name of these registers is `general purpose registers`. Does it mean that we may use any register for any purpose? The simple answer without any details is - no. The [ABI](https://en.wikipedia.org/wiki/Application_binary_interface) and the [calling conventions](https://en.wikipedia.org/wiki/X86_calling_conventions) of an operating system should describe how a certain register is used and why. 

Since these posts described assembly for the Linux x86_64, the following registers have the following meanings:

- `rax` - In most cases could be used as a temporary register to store a temporary value. In a case of call of a [system call](https://en.wikipedia.org/wiki/System_call) it must contain the number of the system call.
- `rdi` - Used to pass `1st` argument to a function.
- `rsi` - Used to pass `2nd` argument to a function.
- `rdx` - Used to pass `3rd` argument to a function.

There is more details related to the Linux x86_64 calling conventions but the description above should be enough for now. Knowing the meaning and the way of use of these registers we can return to the code. What do we need to write a `hello world` program? Usually we just pass a `hello world` string to a library function like [printf](https://en.wikipedia.org/wiki/Printf) or so. But these functions usually goes from a [standard library](https://en.wikipedia.org/wiki/Standard_library) of a programming languages we are using. Assembly does not have a standard library. What to do in this case? Well, we have at least the two following approaches:

- Link our assembly program with C standard library and use [printf](https://man7.org/linux/man-pages/man3/printf.3.html) or any other function that may help us to write a text to the [standard output](https://en.wikipedia.org/wiki/Standard_streams).
- Use the operating system API

We will go through the second way. Each operating system provides an interface that a user level application may use to interact with the operating system. Usually the functions of this API are called `system calls`. Linux kernel also provides set of system calls to interact with it. The full list of system calls with the respective numbers for the Linux `x86_64` could be found [here](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl). Looking in this table, we may see:

```
1	common	write			sys_write
```

The information about the given system call could be found in manual pages. To get information about the `sys_write` system_call we can execute the following command in terminal:

```bash
man 2 write
```

The manual page shows the following function:

```C
ssize_t write(int fd, const void buf[.count], size_t count);
```

which is basically a wrapper around the `sys_write` system call provided by the standard C library. Usually the set of arguments of the system call and the wrapper function is the same. So we safely may assume that the `sys_write` system call is defined like that:

```C
size_t sys_write(unsigned int fd, const char *buf, size_t count);
```

The function expects the following three arguments:

*  `fd` - The file descriptor where to write data.
*  `buf` - The pointer to the buffer from which data will be send to the output.
*  `count` - The number of bytes to be written from the buffer to the file specified by the file descriptor from the first argument.

Now we can understand that the first four lines of the assembly code basically do the two following things:

- Specify the number of the system call (the `sys_write` in our example) that we are going to call.
- Specify the arguments of the `sys_write` system call.

Check the system call table we can know that the `sys_write` system call has the number - `1`. Since the `rax` register should contain the number of the system call that we are going to call, we put `1` into it. After this we put `1` to the `rdi` register. That will be the first argument of the `sys_write`. In our case we want to write the `hello world` string in the terminal, so we put `1` which specifies [standard output](https://en.wikipedia.org/wiki/Standard_streams). The next step is to prepare the second argument of the `sys_write` system call. In our case we pass the address of the `msg` constant to the `rsi` register. At the last but not least step we should specify the length of data we want to write. The length of the `hello, world!` string is `13` bytes, so we pass it to the `rdx` register.

As all parameters of the `sys_write` system call is ready, now we can to call the system call itself. It could be done with the `syscall` instruction. That already should print the `hello, world!` string in our terminal. But if you will build and run only these instructions, you will see the [segmentation fault](https://en.wikipedia.org/wiki/Segmentation_fault) error. The problem is that we need to exit properly from the program. To do that, we have to call the `sys_exit` system call. We need to do the same - fill the `rax` with the number of the `sys_exit` system call and fill the respective registers with the parameters needed for this system call. Let's take a look at the system call [table](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl):

```
60	common	exit			sys_exit
```

We may see that the number of this system call is `60`, so we put this value into the `rax` register. According to the [exit](https://www.man7.org/linux/man-pages/man2/exit.2.html) documentation, this system call expects to get a single argument which is a exit status code. We expect that our program terminates successfully let's just put `0` to the `rdi` register. Our program is ready. Now let's build our program with the following commands:

```bash
nasm -f elf64 -o hello.o hello.asm
ld -o hello hello.o
```

After this we should have an executable file named `hello`. Let's execute it:

```bash
./hello
hello, world!
```

🎉 We have our first assembler program 🎉
