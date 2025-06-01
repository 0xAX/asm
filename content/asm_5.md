# Macros

In the previous chapters, we have got familiar with the basic instructions of assembler programming language. We know how to do basic arithmetic and logic operations. We know how to call functions provided by the Linux kernel called - system calls. We have seen some operations that helps us to operate on string-like data. We have seen already stack operations and many more. In this chapter let's take a look how can we simplify programming process.

Instead of the abstract assembler, we will take a look at the abilities which [NASM](https://nasm.us/) assembler provides us. One of this feature is - macros. 

If you already have some experience programming in other languages, you’ve likely come across the term macro. It can be considered as a term with very wide meaning. However, depending on the technology you are using and the context, [macro](https://en.wikipedia.org/wiki/Macro_(computer_science)) can refer mainly to the two very different things:

- Text substitution. These are the macros you may find in C or C++ programming languages. They performing a simple text replacement before the code compilation happens. This leads to the situation when the compiler never operators with macros but only with the results of them. For example:

   ```C
   #define SQUARE(x) (x * x)
   
   int x = SQUARE(5); // will be replaced with 5 * 5
   ```

- Macros that work at the level of the code structure. For example [lisp](https://lispcookbook.github.io/cl-cookbook/macros.html) or [rust](https://doc.rust-lang.org/book/ch20-05-macros.html) macros. This type of macros generate code by manipulating or expanding parts of the language’s syntax tree.

NASM provides macros that work using the first way. NASM contains a powerful macro processor which provides different abilities for the conditional code execution and text replacement. In the next sections we will see them.

## Single-line NASM macros

NASM provides support for the two form of macros:

- `single-line`
- `multi-line`

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
;; Store the pointer to the first command like argument in the rsi register
mov rsi, argv1
```

If we use the `%define` directive to define a macro, the macro code is evaluated when the macro is used. NASM provides additional directive - `%xdefine` which has the same form as the `%define` directive but it is evaluated immediately at the point of definition.

## Multi-line NASM macros

As the complexity of your programs will grow, you may start to notice repeatable patterns. Single-line macros are good but might be not always enough. That’s where multi-line macros may become useful. Unlike single-line %define macros, which simply substitute a short expression or instruction, multi-line macros allow you to define an entire block of code with parameters

A definition of a multi-line macro starts with the `%macro` NASM directive and ends with the `%endmacro` directive. The general form of a multi-line macro is:

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

For example we can take a look at the multi-line macro below:

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
        ;; Call the `sys_write` system call.
        syscall
%endmacro

;; Definition of the EXIT program
%macro EXIT 1
        ;; Specify the number of the system call (60 is `sys_exit`).
        mov rax, 60
        ;; Set the first argument of `sys_exit` to the first argument of the macro.
        mov rdi, %1
        ;; Call the `sys_exit` system call.
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

The `EXIT` macro expects only one input argument - exit code. 

There is an additional syntax - `n-*` which says that a macro accepts at least `n` arguments.

In the macros body we just initialize the registers according to the [ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf) to call the [system calls](https://en.wikipedia.org/wiki/System_call). The only one difference that you may note is that instead of direct values, we use the input parameters in the macro. The input parameters starts from the `%` symbol followed by the number of the parameter.

The another syntax ability in the multi-line macro is definition of the labels inside of a macro. NASM provides you ability to define a label within the macro. In this case the label name should be prefixed with the `%%`. For example:

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

Besides the self-written macros, NASM provides rich set of already pre-defined macros and directives. In this section we will see some them.

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

### User defined error directives

NASM provides the following three directives to specify user-defined errors or warnings:

- `%error msg`
- `%fatal msg`
- `%warning msg`

In a case of the first two the execution of the program will be interrupted if one of the will be met.

### %strlen directive

Using the `%strlen` directive we may calculate the length of string. So we can rework our `PRINT` macro to accept only single input argument and calculate the length of the given string inside of the macro:

```assembly
;; Definition of the PRINT macro.
%macro PRINT 1
        ;; Specify the number of the system call (1 is `sys_write`).
    	mov rax, 1
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, 1
        ;; Set the second argument of `sys_write` to the reference of the string to print.
        ;; The reference will be stored in the first argument of the macro.
        mov rsi, %1
        ;; Set the third argument of `sys_write` to the length of the string to print.
        mov rdx, %strlen(%1)
        ;; Call the `sys_write` system call.
        syscall
%endmacro
```

### %rotate directive

The `%rotate` directive provides abilities to rotate the input arguments given to the macro. The arguments are rotated to the left by one position. This directive usually useful in conjunction with the next - `%rep` directive.

### %rep directive

This directive provides ability to repeat the given code pre-defined number of times. Its form looks like:

```assembly
%rep COUNT
        ;; repeated instructions
%endrep
```

### STRUC macro

This is not really a NASM macro or directive, but very useful feature of NASM. You can use `STRUC` and `ENDSTRUC` for data structure definition. These allow you to define custom data layouts with named fields. 

The basic syntax is:

```assembly
struc structure-name
        ;; reserve 10 bytes for the first field
        field-1-name: resb 10
        ;; reserve 1 byte for the second field
        field-2-name: resb 1
endstruc
```

After we have defined our structure, we can make so-called "instance" of it. Let's take a look at the following code reworked from the previous example:

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
        ;; Call the `sys_write` system call.
        syscall
%endmacro

;; Definition of the EXIT program
%macro EXIT 1
        ;; Specify the number of the system call (60 is `sys_exit`).
        mov rax, 60
        ;; Set the first argument of `sys_exit` to the first argument of the macro.
        mov rdi, %1
        ;; Call the `sys_exit` system call.
        syscall
%endmacro

;; Define person structure
struc person
        ;; Person name
        .name resb 10
        ;; Person age
        .age  resb 1
endstruc
        
;; Definition of the .data section.
section .data
        ;; ASCII code of the new line symbol ('\n').
        newline: db 0xA
        ;; Instance of the person structure.
        p: istruc person
           ;; Person name
           at person.name, db "Alex"
           ;; Person age
           at person.age,  db 25
        iend

;; Definition of the .text section.
section .text
        ;; Reference to the entry point of our program.
        global _start

;; Entry point of the program.
_start:
        ;; Print the person name defined by the `p`
        PRINT p + person.name, 4
        ;; Print new line message with the length 1.
        PRINT newline, 1
        ;; Exit from the program. The 0 status code is success.
        EXIT 0
```

Looking at the example above we may see how to use structures and their instances.

## Example

Traditionally each previous chapter was ended with an example. All of the previous examples were pretty trivial. They may look a bit like an artificial programs that do not do anything useful. Since we already know assembler a little bit we can take a look at something practical. In this time I would suggest to take a look at the real code from the very popular open source project - [ffmpeg](https://en.wikipedia.org/wiki/FFmpeg). It has significant amount of code written in assembly mainly for the sake of performance. You can be sure in it if you will try to find all the files with the `.asm` extension. Luckily, this project also uses NASM, so most of things should be similar to us.

Let's take a look at the definition of the macro `REPX` defined in the [x86inc.asm](https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/x86/x86inc.asm) source code file:

```assembly
;; Repeats an instruction/operation for multiple arguments.
;; Example usage: "REPX {psrlw x, 8}, m0, m1, m2, m3"
%macro REPX 2-* ; operation, args
    %xdefine %%f(x) %1
    %rep %0 - 1
        %rotate 1
        %%f(%1)
    %endrep
%endmacro
```

As you may see, it has some comments. So at least we know from the beginning what this macro should do. Now let's try to understand how it does its job. 

First of all the definition of the macro is a little bit new to us. The `2-*` notation means that the macro accepts at least 2 input parameters.

The first line in the macro body defines the local `%%f` macro. This macro will be expanded into the first argument of the `REPX` macro. Since the `xdefine` directive was used it captured the first argument of the `REPX` macro whatever will happen with it next. So if the macro was used like this:

```assembly
REPX {psrlw x, 8}, m0, m1, m2, m3
```

the `%%f` macro is bound to the `{psrlw x, 8}`.

The next instruction in this macro is the `%rep` directive. In our case it will repeat the given body `%0 - 1` times. The `%0` here is the number of the arguments given to the `REPX` macro.

The loop in this macro consists of the two lines of code. The first one contains `%rotate` directive which rotates the arguments list by 1 position. It moves the second argument to the first position, the third argument to the third position, and so on. The last line of this macro applies the operation stored in `%%f` to the given argument after rotation. This operation is repeated for the all arguments of the `REPX` macro except the first one.

As a result of this macro, for example the instruction:

```assembly
REPX {pmulhuw x, m7}, m0, m1, m2, m3
```

we will have the following expandsion of the macro:

```assembly
pmulhuw m0, m7
pmulhuw m1, m7
pmulhuw m2, m7
pmulhuw m3, m7
```

We have just tried to understand real-world assembly code!

## Conclusion

As we have seen in this chapter, macros are the powerful tool that may help you to reduce complexity in your assembly programming.

For more information about NASM macros, go to the [official documentation](https://nasm.us/doc/nasmdoc4.html).
