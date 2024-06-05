
Some time ago i started to write series of blog posts about assembly programming for x86_64. You can find it by asm tag. Unfortunately i was busy last time and there were not new post, so today I continue to write posts about assembly, and will try to do it every week.

Today we will look at strings and some strings operations. We still use nasm assembler, and linux x86_64.

## Reverse string

Of course when we talk about assembly programming language we can't talk about string data type, actually we're dealing with array of bytes. Let's try to write simple example, we will define string data and try to reverse and write result to stdout. This tasks seems pretty simple and popular when we start to learn new programming language. Let's look on implementation.

First of all, I define initialized data. It will be placed in data section (You can read about sections in part):

```assembly
section .data
		SYS_WRITE equ 1
		STD_OUT   equ 1
		SYS_EXIT  equ 60
		EXIT_CODE equ 0

		NEW_LINE db 0xa
		INPUT db "Hello world!"
```

Here we can see four constants:

* `SYS_WRITE` - 'write' syscall number
* `STD_OUT` - stdout file descriptor
* `SYS_EXIT` - 'exit' syscall number
* `EXIT_CODE` - exit code

syscall list you can find - here. Also there defined:

* `NEW_LINE` - new line (\n) symbol
* `INPUT` - our input string, which we will reverse

Next we define bss section for our buffer, where we will put reversed string:

```assembly
section .bss
		OUTPUT resb 12
```

Ok we have some data and buffer where to put result, now we can define text section for code. Let's start from main _start routine:

```assembly
_start:
		mov rsi, INPUT
		xor rcx, rcx
		cld
		mov rdi, $ + 15
		call calculateStrLength
		xor rax, rax
		xor rdi, rdi
		jmp reverseStr
```

Here are some new things. Let's see how it works: First of all we put INPUT address to si register at line 2, as we did for writing to stdout and write zeros to rcx register, it will be counter for calculating length of our string. At line 4 we can see cld operator. It resets df flag to zero. We need in it because when we will calculate length of string, we will go through symbols of this string, and if df flag will be 0, we will handle symbols of string from left to right. Next we call calculateStrLength function. I missed line 5 with mov rdi, $ + 15 instruction, i will tell about it little later. And now let's look at calculateStrLength implementation:

```assembly
calculateStrLength:
		;; check is it end of string
		cmp byte [rsi], 0
		;; if yes exit from function
		je exitFromRoutine
		;; load byte from rsi to al and inc rsi
		lodsb
		;; push symbol to stack
		push rax
		;; increase counter
		inc rcx
		;; loop again
		jmp calculateStrLength
```

As you can understand by it's name, it just calculates length of INPUT string and store result in rcx register. First of all we check that rsi register doesn't point to zero, if so this is the end of string and we can exit from function. Next is lodsb instruction. It's simple, it just put 1 byte to al register (low part of 16 bit ax) and changes rsi pointer. As we executed cld instruction, lodsb everytime will move rsi to one byte from left to right, so we will move by string symbols. After it we push rax value to stack, now it contains symbol from our string (lodsb puts byte from si to al, al is low 8 bit of rax). Why we did push symbol to stack? You must remember how stack works, it works by principle LIFO (last input, first output). It is very good for us. We will take first symbol from si, push it to stack, than second and so on. So there will be last symbol of string at the stack top. Than we just pop symbol by symbol from stack and write to OUTPUT buffer. After it we increment our counter (rcx) and loop again to the start of routine.

Ok, we pushed all symbols from string to stack, now we can jump to exitFromRoutine return to _start there. How to do it? We have ret instruction for this. But if code will be like this:

```assembly
exitFromRoutine:
		;; return to _start
		ret
```

It will not work. Why? It is tricky. Remember we called calculateStrLength at _start. What occurs when we call a function? First of all function's parameters pushes to stack from right to left. After it return address pushes to stack. So function will know where to return after end of execution. But look at calculateStrLength, we pushed symbols from our string to stack and now there is no return address of stack top and function doesn't know where to return. How to be with it. Now we must take a look to the weird instruction before call:

```assembly
    mov rdi, $ + 15
```

First all:

* `$` - returns position in memory of string where $ defined
* `$$` - returns position in memory of current section start

So we have position of mov rdi, $ + 15, but why we add 15 here? Look, we need to know position of next line after calculateStrLength. Let's open our file with objdump util:

```assembly
objdump -D reverse

reverse:     file format elf64-x86-64

Disassembly of section .text:

00000000004000b0 <_start>:
  4000b0:	48 be 41 01 60 00 00 	movabs $0x600141,%rsi
  4000b7:	00 00 00
  4000ba:	48 31 c9             	xor    %rcx,%rcx
  4000bd:	fc                   	cld
  4000be:	48 bf cd 00 40 00 00 	movabs $0x4000cd,%rdi
  4000c5:	00 00 00
  4000c8:	e8 08 00 00 00       	callq  4000d5 <calculateStrLength>
  4000cd:	48 31 c0             	xor    %rax,%rax
  4000d0:	48 31 ff             	xor    %rdi,%rdi
  4000d3:	eb 0e                	jmp    4000e3 <reverseStr>
```

We can see here that line 12 (our mov rdi, $ + 15) takes 10 bytes and function call at line 16 - 5 bytes, so it takes 15 bytes. That's why our return address will be mov rdi, $ + 15. Now we can push return address from rdi to stack and return from function:

```assembly
exitFromRoutine:
		;; push return addres to stack again
		push rdi
		;; return to _start
		ret
```

Now we return to start. After call of the `calculateStrLength` we write zeros to rax and rdi and jump to reverseStr label. It's implementation is following:

```assembly
reverseStr:
		cmp rcx, 0
		je printResult
		pop rax
		mov [OUTPUT + rdi], rax
		dec rcx
		inc rdi
		jmp reverseStr
```

Here we check our counter which is length of string and if it is zero we wrote all symbols to buffer and can print it. After checking counter we pop from stack to rax register first symbol and write it to OUTPUT buffer. We add rdi because in other way we'll write symbol to first byte of buffer. After this we increase rdi for moving next by OUTPUT buffer, decrease length counter and jump to the start of label.

After execution of reverseStr we have reversed string in OUTPUT buffer and can write result to stdout with new line:

```assembly
printResult:
		mov rdx, rdi
		mov rax, 1
		mov rdi, 1
		mov rsi, OUTPUT
                syscall
		jmp printNewLine

printNewLine:
		mov rax, SYS_WRITE
		mov rdi, STD_OUT
		mov rsi, NEW_LINE
		mov rdx, 1
		syscall
		jmp exit
```

and exit from the our program:

```assembly
exit:
		mov rax, SYS_EXIT
		mov rdi, EXIT_CODE
		syscall
```

That's all, now we can compile our program with:

```assembly
all:
	nasm -g -f elf64 -o reverse.o reverse.asm
	ld -o reverse reverse.o

clean:
	rm reverse reverse.o
```

and run it:

![result](/content/assets/result_asm_4.png)

## String operations

Of course there are many other instructions for string/bytes manipulations:

* `REP` - repeat while rcx is not zero
* `MOVSB` - copy a string of bytes (MOVSW, MOVSD and etc..)
* `CMPSB` - byte string comparison
* `SCASB` - byte string scanning
* `STOSB` - write byte to string
