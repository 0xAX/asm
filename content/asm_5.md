# Macros

In the previous chapters, we have got familiar with the basic instructions of assembler programming language. We know how to do basic arithmetic and logic operations. We know how to call functions provided by the Linux kernel called - system calls. We have seen some operations that helps us to operate on string-like data. We have seen already stack operations and many more. In this chapter let's take a look how can we simplify programming process.

Instead of the abstract assembler, we will take a look at the abilities which [NASM](https://nasm.us/) assembler provides us. One of this feature is - macros. 

If you already have some experience programming in other languages, you’ve likely come across the term macro. It can be considered as a term with very wide meaning. However, depending on the technology you are using and the context, [macro](https://en.wikipedia.org/wiki/Macro_(computer_science)) can refer mainly to the two very different things:

- Text substitution. These are the macros you may find in C or C++ programming languages. They performing a simple text replacement before the code compilation happens. This leads to the situation when the compiler never operatos with macros but only with the results of them. For example:

   ```C
   #define SQUARE(x) (x * x)
   
   int x = SQUARE(5); // will be replaced with 5 * 5
   ```

- Macros that work at the level of the code structure. For example [lisp](https://lispcookbook.github.io/cl-cookbook/macros.html) or [rust](https://doc.rust-lang.org/book/ch20-05-macros.html) macros. This type of macros generate code by manipulating or expanding parts of the language’s syntax tree.

NASM provides macros that work using the first way. NASM contains a powerful macro processor which provides different abilities for the conditional code execution and text replacement. In the next sections we will see them.

## Single-line NASM macros

NASM provides support for the two form of macros:

- `single-line`
- `multiline`

All the single-line macro must start from `%define` directive. The form of this directive is following:

```assembly
%define macro_name(parameter) value
```

This is very similar to an usual C-like macro that we may define using the `#define` directive. For example, using this directive we can create the following single-line macros:

```assembly
;; Define a symbolic name for the location of argv (CLI arguments) on the stack
;; In x86-64 System V ABI, the stack layout at program start is:
;; [rsp]         → argc
;; [rsp + 8]     → argv[0]
;; [rsp + 16]    → argv[1]
;; ...

;; Pointer to the number of command line arguments
define argc [rsp]

;; Pointer to argv[0] (program name)
%define argv0 qword [rsp + 8]

;;Pointer to argv[1] (first actual CLI arg)
%define argv1 qword [rsp + 16]
```

Now we can use our definition in the code:

```assembly
;; Store the number of command line arguments in the rax register
mov rax, argc
;; Store the pointer to the first command like arugment in the rsi register
mov rsi, argv1
```

## Multiline NASM macros

As the complexity of your programs will grow, you may start to notice repeatable patterns. Single-line macros are good but might be not always enough. That’s where multiline macros may become useful. Unlike single-line %define macros, which simply substitute a short expression or instruction, multiline macros allow you to define an entire block of code with parameters

A definition of a multiline macro starts with the `%macro` NASM directive and ends with the `%endmacro` directive. The general form of a multiline macro is:

```assembly
%macro name number_of_parameters
    instruction
    instruction
    instruction
    ...
    ...
    ...
%endmacro
```

For example we can take a look at the multiline macro below:

```assembly
%macro prolog 0
        push rbp
        mov rbp,rsp
%endmacro
```

After we defined our macro we can use it in the code:

```assembly
_start:
        prolog
```

In the previous chapters we have used very often code that prints the data. To not write this code-snippet every time, like for example we did in the example of the [previous chapter](https://github.com/0xAX/asm/blob/master/content/asm_4.md) we can write a macro. Let's take a look at it:

```assembly
;; Definition of the PRINT macro.
%macro PRINT 2
        ;; Specify the number of the system call (1 is `sys_write`).
    	mov rax, 1
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, 1
        ;; Set the second argument of `sys_write` to the reference of the string to print.
        ;; The reference will be stored in the first argument of the macro.
        mov rsi, %1
        ;; Set the third argument of `sys_write` to the length of the string to print.
        ;; The reference will be stored in the second argument of the macro.
        mov rdx, %2
        syscall
%endmacro

;; Definition of the EXIT program
%macro EXIT 1
        ;; Specify the number of the system call (60 is `sys_exit`).
        mov rax, 60
        ;; Set the first argument of `sys_exit` to the first argument of the macro.
        mov rdi, %1
        syscall
%endmacro
```

After we have defined our macros, we can use them in our code. For example:

```assembly
;; Definition of the .data section.
section .data
        ;; The first message to print.
        msg_1   db      "Message 1"
        ;; The second message to print.
        msg_2   db      "Message 2"
        ;; ASCII code of the new line symbol ('\n').
        newline db      0xA

;; Definition of the .text section.
section .text
        ;; Reference to the entry point of our program.
        global _start

;; Entry point of the program.
_start:
        ;; Print the first message with the length 9.
        PRINT msg_1, 9
        ;; Print new line message with the length 1.
        PRINT newline, 1
        ;; Print the first message with the length 9.
        PRINT msg_2, 9
        ;; Print new line message with the length 1.
        PRINT newline, 1
        ;; Exit from the program. The 0 status code is success.
        EXIT 0
```

Now let's try to go through the macros definitions and try to understand how they work. The macro definition starts from the `%macro` directive and definition of the name of the macro and number of input parameters. Our `PRINT` macro will expect two arguments:

- The reference to the string that is going to be printed
- The length of this string

The `EXIT` macro expects only one input argument - exit code. In the macros body we just initialize the registers according to the [ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf) to call the [system calls](https://en.wikipedia.org/wiki/System_call). The only one difference that you may note is that instead of direct values, we use the input parameters in the macro. The input parameters starts from the `%` symbol followed by the number of the parameter.

The another syntax ability in the multiline macro is definition of the labels inside of a macro. NASM provides you ability to define a label within the macro. In this case the label name should be prefixed with the `%%`. For example:

```assembly
%macro retg 0
        jg %%label
        ret
%%label:
        ...
        ...
        ...
%endmacro
```
 
## Conditional assembly

Another useful ability is to write conditional code. To do that, NASM provides the following standard directives:

- `ifdef/endif` - assembly code will be built if and only if the condition is true
- `ifmacro/endif` - check the existence of the given macro name
- `if/elif/else/endif` - check the numeric expression
- `ifenv/elifenv/elifnenv/endif` - check if an environment variable exists
- And others like `ifempty`, `iftoken`, and `ifid`.

For example we can slightly change the previous example:

```assembly
;; Entry point of the program.
_start:
        ;; Print the first message with the length 9.
        PRINT msg_1, 9
        ;; Print new line message with the length 1.
        PRINT newline, 1
%ifdef DEBUG
        ;; Print the first message with the length 9.
        PRINT msg_2, 9
        ;; Print new line message with the length 1.
        PRINT newline, 1
%endif
        ;; Exit from the program. The 0 status code is success.
        EXIT 0
```

The second message here will be printed if and only if - `DEBUG` is defined. If we run the code as is, we will see the only the first message is printed:

```bash
~$ nasm -f elf64 -o test.o test.asm && ld -o test test.o && ./test
Message 1
```

Although if we will pass `DEBUG` to the program or define it, we will see the both messages are printed:

```bash
~$ nasm -DDEBUG -f elf64 -o test.o test.asm && ld -o test test.o && ./test
Message 1
Message 2
```

## Useful standard macros

Besieds the self-written macros, NASM provides rich set of already pre-defined macros and directives. In this section we will see some them.

### %include directive

We can include another assembly file into our file and jump to the labels defined in it, or call procedures defined there. The usage is pretty trivial, just specify the name of the assembly file you want to include:

```assembly
%include "helpers.asm"
```

### %assign directive

The single-line macro also can be defined with the special directive - `%assign`. The difference from the `%define` directive, is that using the `%assign` directive you can define a macro without parameters that will expand to a numeric value.

For example:

```assembly
%assign increment_i_var i + 1
```

### %defstr directive

The `%defstr` directive exists to define a macro without parameters that will expand to a quoted string.

For example:

```assembly
%defstr hello_world_msg "Hello world!"
```

### %! directive

Sometimes it can be useful to get a value of an environment variable. For this, NASM provides the special `%!` directive that can be used to get a value from the given environment variable. For example:

```assembly
%defstr HOME %!HOME
```

### User defined erorrs directives

NASM provides the following three directives to specify user-defined errors or warnings:

- `%error msg`
- `%fatal msg`
- `%warning msg`

In a case of the first two the execution of the program will be interrupted if one of the will be met.

### STRUC macro

This is not really a NASM macro or directive, but very useful feature of NASM. You can use `STRUC` and `ENDSTRUC` for data structure defintion. These allow you to define custom data layouts with named fields. The basic syntax is:

```assembly
struc person
        name: resb 10
        age:  resb 1
endstruc
```

After we have defined our structure, we can make so-called "instance" of it. Let's take a look at the following code:

```assembly
TODO
;; Definition of the .data section.
section .data
        p: istruc person
            at name db "Alex"
            at age  db 25
        iend

section .text
_start:
    mov rax, [p + person.name]
```

## Example

TODO

## Conclusion

TODO official docs - https://nasm.us/doc/nasmdoc4.html

TODO: 

 - %xdefine
 - %[...]
 - %assign
 - 4.2.12 Conditional Comma Operator: %,
 - %strlen
 - 4.4 Preprocessor Functions
