# Macros

In the previous chapters, we've become familiar with the basic instructions of the assembler programming language. We know how to do basic arithmetic and logic operations. We know how to call functions provided by the Linux kernel called system calls. We have seen some operations that help us operate on string-like data. We have seen stack operations and many more. In this chapter, let's take a look at how we can simplify the programming process.

Instead of the abstract assembler, in this chapter, we will look at the abilities that [NASM](https://nasm.us/) assembler provides us. One of these features is macros.

If you already have some programming experience in other languages, you’ve likely come across the term macro. It can be considered as a term with a very wide meaning. However, depending on the technology you are using and the context, [macro](https://en.wikipedia.org/wiki/Macro_(computer_science)) can refer mainly to two very different things:

- Text substitution. These are the macros you may find in C or C++ programming languages. They perform a simple text replacement before code compilation happens. This leads to a situation where the compiler operates with the results of the macros, not the macros themselves. For example:

    ```C
    #define SQUARE(x) (x * x)

    int x = SQUARE(5); // will be replaced with 5 * 5
    ```

- Macros that operate at the code structure level, such as [lisp](https://lispcookbook.github.io/cl-cookbook/macros.html) or [rust](https://doc.rust-lang.org/book/ch20-05-macros.html) macros. This type of macro generates code by manipulating or expanding parts of the language’s syntax tree.

NASM provides macros that work according to the first method. It includes a powerful macro processor that provides different capabilities for conditional code execution and text replacement. In the following sections, we will explore these features.

## Single-line NASM macros

NASM provides support for two forms of macros:

- `single-line`
- `multi-line`

All single-line macros must start from the `%define` directive. The form of this directive is as follows:

```assembly
%define macro_name(parameter) value
```

This is very similar to a usual C-like macro that we can define using the `#define` directive. For example, using this directive, we can create the following single-line macros:

```assembly
;; Define a symbolic name for the location of argv (CLI arguments) on the stack
;; In x86-64 System V ABI, the stack layout at the program's start is:
;; [rsp]         → argc
;; [rsp + 8]     → argv[0]
;; [rsp + 16]    → argv[1]
;; ...

;; Pointer to the number of command line arguments
define argc [rsp]

;; Pointer to argv[0] (program name)
%define argv0 qword [rsp + 8]

;; Pointer to argv[1] (first actual CLI argument)
%define argv1 qword [rsp + 16]
```

Now we can use our definition in the code:

```assembly
;; Store the number of command line arguments in the rax register
mov rax, argc
;; Store the pointer to the first command line argument in the rsi register
mov rsi, argv1
```

When we use the `%define` directive to define a macro, the macro is expanded when it is used. NASM also provides the `%xdefine` directive, which looks similar but evaluates the macro immediately at the point of definition.

## Multi-line NASM macros

As the complexity of your programs grows, you may start to notice repeatable patterns. Single-line macros are good, but might not always be enough. That’s where multi-line macros may become useful. Unlike single-line `%define` macros, which simply substitute a short expression or instruction, multi-line macros allow you to define an entire block of code with parameters.

A definition of a multi-line macro starts with the `%macro` NASM directive and ends with the `%endmacro` directive. The general form of a multi-line macro is:

```assembly
%macro name number_of_parameters
        instruction1
        instruction2
        instruction3
        ...
        ...
        ...
        instructionN
%endmacro
```

For example:

```assembly
%macro prolog 0
        push rbp
        mov rbp,rsp
%endmacro
```

After we defined our macro, we can use it in the code:

```assembly
_start:
        prolog
```

In the previous chapters, we often used code that prints data. To not write this code snippet every time, like for example in the [previous chapter](https://github.com/0xAX/asm/blob/master/content/asm_4.md), we can write a macro. Let's take a look at it:

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
        msg_1 db "Message 1"
        ;; The second message to print.
        msg_2 db "Message 2"
        ;; ASCII code of the new line symbol ('\n').
        newline db 0xA

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
        ;; Print the second message with the length 9.
        PRINT msg_2, 9
        ;; Print new line message with the length 1.
        PRINT newline, 1
        ;; Exit from the program. The 0 status code is success.
        EXIT 0
```

Now let's go through the macro definitions and see how they work. A macro definition starts from the `%macro` directive, followed by the macro’s name and the number of input parameters it expects. For example, our `PRINT` macro expects two arguments:

- The reference to the string that we want to print
- The length of this string

The `EXIT` macro expects only one input argument - exit code. 

There is also an additional syntax (`n-*`) that indicates a macro accepts at least `n` arguments.

In the macro's body, we initialize the registers according to the [ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf) to make [system calls](https://en.wikipedia.org/wiki/System_call). The only difference you may notice is that instead of using direct values, we use input parameters. These parameters start with the `%` symbol, followed by the number of the parameter (`%1`, `%2`, etc).

Another syntax ability in the multi-line NASM macros is the possibility to define labels inside a macro. In this case, the label name should be prefixed with `%%`. For example:

```assembly
%macro retg 0
        jg %%label
        ret
%%label:
        instruction1
        instruction2
        instruction3
        ...
%endmacro
```
 
## Conditional assembly

Another useful feature that NASM assembly offers is the ability to write conditional code. To do that, NASM provides the following standard directives:

- `ifdef/endif` - assembly code will be built only if the condition is true
- `ifmacro/endif` - check the existence of the given macro name
- `if/elif/else/endif` - check the numeric expression
- `ifenv/elifenv/elifnenv/endif` - check if an environment variable exists
- And others, like `ifempty`, `iftoken`, and `ifid`.

For example, we can slightly change the previous example and use `%ifdef DEBUG`:

```assembly
;; Entry point of the program.
_start:
        ;; Print the first message with the length 9.
        PRINT msg_1, 9
        ;; Print new line message with the length 1.
        PRINT newline, 1
%ifdef DEBUG
        ;; Print the second message with the length 9.
        PRINT msg_2, 9
        ;; Print new line message with the length 1.
        PRINT newline, 1
%endif
        ;; Exit from the program. The 0 status code is success.
        EXIT 0
```

In this code snippet, the second message will be printed only if `DEBUG` is defined. If we run the code as is, we will see that only the first message is printed:

```bash
~$ nasm -f elf64 -o test.o test.asm && ld -o test test.o && ./test
Message 1
```

However, if we pass `DEBUG` to the program or define it, we will see that both messages are printed:

```bash
~$ nasm -D DEBUG -f elf64 -o test.o test.asm && ld -o test test.o && ./test
Message 1
Message 2
```

## Useful standard macros

Besides the self-written macros, NASM provides a rich set of pre-defined macros and directives. In this section, we will see some of them.

### %include directive

We can include another assembly file into our file and jump to the labels defined in it, or call procedures defined there. The usage is pretty trivial - just specify the name of the assembly file you want to include:

```assembly
%include "helpers.asm"
```

### %assign directive

You can also define a single-line macro with the special directive - `%assign`. The difference from the `%define` directive is that, by using the `%assign` directive, you can define a macro without parameters that will expand to a numeric value.

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

Sometimes it can be useful to get the value from the given environment variable. For this, NASM provides the special `%!` directive. For example:

```assembly
%defstr HOME %!HOME
```

### User-defined error directives

NASM provides the following directives to specify user-defined errors or warnings:

- `%error msg`
- `%fatal msg`
- `%warning msg`

For the first two directives, the program prints the message given as an argument, and the program's execution is interrupted. In the case of the `%warning` directive, only the message is printed.

### %strlen directive

Using the `%strlen` directive, we can calculate the length of a string. Using `%strlen`, we can rework our `PRINT` macro to accept only a single input argument and calculate the length of the given string inside the macro:

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

The `%rotate` directive allows you to rotate the input arguments given to the macro. The arguments are rotated to the left by one position. This directive is usually used together with the next `%rep` directive.

### %rep directive

This directive allows you to repeat the given code for a pre-defined number of times. Its form looks like:

```assembly
%rep COUNT
        ;; repeated instructions
%endrep
```

### STRUC macro

This is not really a NASM macro or directive, but a very useful NASM feature. You can use `STRUC` and `ENDSTRUC` to define custom data layouts with named fields.

The basic syntax is:

```assembly
struc structure-name
        ;; Reserve 10 bytes for the first field
        field-1-name: resb 10
        ;; Reserve 1 byte for the second field
        field-2-name: resb 1
endstruc
```

After we have defined our structure, we can make a so-called "instance" of it. Let's take a look at the code reworked from the previous example to see how to use structures and their instances:

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

;; Define a "person" structure
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

## Example

Traditionally, each chapter ends with an example. So far, the examples we've looked at were fairly simple — they might even look a bit artificial, since they didn't do anything particularly useful. Now that we know assembler a little bit more, we can take a look at something more practical. This time, let's have a look at the real code from the very popular open source project - [ffmpeg](https://en.wikipedia.org/wiki/FFmpeg). FFmpeg contains a significant amount of code written in assembly, mostly written for performance reasons. You can see this for yourself by searching for all files with the `.asm` extension. Fortunately, the project uses NASM, so much of the code will look familiar.

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

As you may see, this macro contains comments that help to understand from the beginning what it should do. Let's try to understand how this macro does its job.

First of all, the definition of the macro is a little bit new to us. The `2-*` notation means that the macro accepts at least 2 input parameters. The macro uses the first argument as an instruction and applies it to the remaining arguments.

The first line in the macro body defines the local macro named `%%f`. This macro is expanded to the first argument of the `REPX` macro. Because the `xdefine` directive is used instead of `%define`, it captures the value of the first argument of the `REPX` macro as is. For example, `%%f` will be bound to `{psrlw x, 8}`, if the macro is used like this:

```assembly
REPX {psrlw x, 8}, m0, m1, m2, m3
```

The macro name is prefixed with `%%` to define a uniquely scoped macro, with the name limited to this invocation of the `REPX` macro. This prevents clashes with other macros named `f` elsewhere.

The next instruction in this macro is the `%rep` directive. In our case, it repeats the given body `%0 - 1` times. The `%0` here is the number of the arguments given to the `REPX` macro. Since the first argument of the macro is an instruction that we need to repeat for the given arguments, we skip one repetition by doing `%0 - 1`.

The loop in this macro consists of two lines of code:

- The first line contains the `%rotate` directive, which rotates the arguments by 1 position at each iteration of the loop. It moves the second argument to the first position, the third argument to the second position, and so on.
- The second line contains the `%%f` macro invocation, which was previously defined to expand into the first argument of the `REPX` macro. It replaces `x` in the first argument of `REPX` with the parameter given to the `%%f` macro. By passing `%1` to `%%f`, the macro expands to the original first argument of the REPX macro, replacing the placeholder `x` with each of the subsequent arguments of `REPX`. On each iteration of the loop, `x` is substituted with the next argument of the `REPX` macro starting from the second because of the previous `rotate` definition — so the first iteration uses the second argument of `REPX`, the second iteration uses the third, and so on. This is repeated until all arguments are processed.

So, when we use a macro with such arguments:

```assembly
REPX {psrlw x, 8}, m0, m1, m2, m3
```

It will be expanded to:

```assembly
pmulhuw m0, m7
pmulhuw m1, m7
pmulhuw m2, m7
pmulhuw m3, m7
```

We’ve just explored a real-world assembly code! 🎉 🎉 🎉 

## Conclusion

As we have seen in this chapter, macros are a powerful tool that can help reduce complexity in assembly programming.

For more information about NASM macros, go to the [official documentation](https://nasm.us/doc/nasmdoc4.html).
