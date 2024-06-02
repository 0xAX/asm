+++
Categories = ["assembler"]
Tags = ["linux", "x86_64", "assembly"]
date = "2014-09-20"
title = "Say hello to x86_64 Assembly [part 5]"
+++

It is a fifth part of Say hello to x86_64 Assembly and here we will look at macros. It will not be blog post about x86_64, mainly it will be about nasm assembler and it's preprocessor. If you're interesting in it read next.

Macros
-------------------------

NASM supports two form of macro:

* single-line
* multiline

All single-line macro must start from %define directive. It form is following:

```assembly
%define macro_name(parameter) value
```

Nasm macro behaves and looks very similar as in C. For example, we can create following single-line macro:

```assembly
%define argc rsp + 8
%define cliArg1 rsp + 24
```

and than use it in code:

```assembly
;;
;; argc will be expanded to rsp + 8
;;
mov rax, [argc]
cmp rax, 3
jne .mustBe3args
```

Multiline macro starts with %macro nasm directive and end with %endmacro. It general form is following:

```assembly
%macro number_of_parameters
    instruction
    instruction
    instruction
%endmacro
```

For example:

```assembly
%macro bootstrap 1
          push ebp
          mov ebp,esp
%endmacro
```

And we can use it:

```assembly
_start:
    bootstrap
```

For example let's look at PRINT macro:

```assembly
%macro PRINT 1
    pusha
    pushf
    jmp %%astr
%%str db %1, 0
%%strln equ $-%%str
%%astr: _syscall_write %%str, %%strln
popf
popa
%endmacro

%macro _syscall_write 2
	mov rax, 1
        mov rdi, 1
        mov rsi, %%str
        mov rdx, %%strln
        syscall
%endmacro
```

Let's try to go through it macro and understand how it works: At first line we defined PRINT macro with one parameter. Than we push all general registers (with pusha instruction) and flag register with (with pushf instruction). After this we jump to %%astr label. Pay attention that all labels which defined in macro must start with %%. Now we move to __syscall_write macro with 2 parameter. Let's look on __syscall_write implementation. You can remember that we use write system call in all previous posts for printing string to stdout. It looks like this:

```assembly
;; write syscall number
mov rax, 1
;; file descriptor, standard output
mov rdi, 1
;; message address
mov rsi, msg
;; length of message
mov rdx, 14
;; call write syscall
syscall
```

In our __syscall_write macro we define first two instruction for putting 1 to rax (write system call number) and rdi (stdout file descriptor). Than we put %%str to rsi register (pointer to string), where %%str is local label to which is get first parameter of PRINT macro (pay attention that macro parameter access by $parameter_number) and end with 0 (every string must end with zero). And %%strlen which calculates string length. After this we call system call with syscall instruction and that's all.

Now we can use it:

```assembly
label: PRINT "Hello World!"
```

Useful standard macros
---------------------------------

NASM supports following standard macros:

STRUC
--------

We can use `STRUC` and `ENDSTRUC` for data structure defintion. For example:

```assembly
struc person
   name: resb 10
   age:  resb 1
endstruc
```

And now we can make instance of our structure:

```assembly
section .data
    p: istruc person
      at name db "name"
      at age  db 25
    iend

section .text
_start:
    mov rax, [p + person.name]
```

%include
----------------

We can include other assembly files and jump to there labels or call functions with %include directive.
