
It is sixth part of Say hello to x86_64 Assembly and here we will look on AT&T assembler syntax. Previously we used nasm assembler in all parts, but there are some another assemblers with different syntax, fasm, yasm and others. As i wrote above we will look on gas (GNU assembler) and difference between it's syntax and nasm. GCC uses GNU assembler, so if you see at assembler output for simple hello world:

```C
#include <unistd.h>

int main(void) {
	write(1, "Hello World\n", 15);
	return 0;
}
```

You will see following output:

```assembly
	.file	"test.c"
	.section	.rodata
.LC0:
	.string	"Hello World\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$15, %edx
	movl	$.LC0, %esi
	movl	$1, %edi
	call	write
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 4.9.1-16ubuntu6) 4.9.1"
	.section	.note.GNU-stack,"",@progbits
```

Looks different then nasm Hello world, let's look on some differences.

## AT&T syntax

### Sections

I don't know how about you, but when I start to write assembler program, usually I'm starting from sections definition. Let's look on simple example:

```assembly
.data
    //
    // initialized data definition
    //
.text
    .global _start

_start:
    //
    // main routine
    //
```

You can note two little differences here:

* Section definition starts with . symbol
* Main routine defines with .globl instead global as we do it in nasm

Also gas uses another directives for data defintion:

```assembly
.section .data
    // 1 byte
    var1: .byte 10
    // 2 byte
    var2: .word 10
    // 4 byte
    var3: .int 10
    // 8 byte
    var4: .quad 10
    // 16 byte
    var5: .octa 10

    // assembles each string (with no automatic trailing zero byte) into consecutive addresses
    str1: .asci "Hello world"
    // just like .ascii, but each string is followed by a zero byte
    str2: .asciz "Hello world"
    // Copy the characters in str to the object file
    str3: .string "Hello world"
```

Operands order
When we write assembler program with nasm, we have following general syntax for data manipulation:

```assembly
mov destination, source
```

With GNU assembler we have back order i.e.:

```assembly
mov source, destination
```

For example:

```assembly
;;
;; nasm syntax
;;
mov rax, rcx

//
// gas syntax
//
mov %rcx, %rax
```

Also you can not here that registers starts with % symbol. If you're using direct operands, need to use `$` symbol:

```assembly
movb $10, %rax
```

### Size of operands and operation syntax

Sometimes when we need to get part of memory, for example first byte of 64 register, we used following syntax:

```assembly
mov ax, word [rsi]
```

There is another way for such operations in gas. We don't define size in operands but in instruction:

```assembly
movw (%rsi), %ax
```

GNU assembler has 6 postfixes for operations:

* `b` - 1 byte operands
* `w` - 2 bytes operands
* `l` - 4 bytes operands
* `q` - 8 bytes operands
* `t` - 10 bytes operands
* `o` - 16 bytes operands

This rule is not only mov instruction, but also for all another like addl, xorb, cmpw and etc...

### Memory access

You can note that we used () brackets in previous example instead [] in nasm example. To dereference values in parentheses are used GAS: (%rax), for example:

```assembly
movq -8(%rbp),%rdi
movq 8(%rbp),%rdi
```

### Jumps

GNU assembler supports following operators for far functions call and jumps:

```assembly
lcall $section, $offset
```

Far jump - a jump to an instruction located in a different segment than the current code segment but at the same privilege level, sometimes referred to as an intersegment jump.

### Comments

GNU assembler supports 3 types of comments:

```
    # - single line comments
    // - single line comments
    /* */ - for multiline comments
```
