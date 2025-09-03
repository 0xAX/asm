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

;; Definition of the .bss section.
section .bss
        ;; Output buffer where the reversed string will be stored.
        OUTPUT  resb 1

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
        mov rdi, OUTPUT
        ;; Call the reverseStringAndPrint procedure.
        call reverseStringAndPrint

;; Calculate the length of the input string and prepare to reverse it.
reverseStringAndPrint:
        ;; Compare the first element in the given string with the `NUL` terminator (end of the string).
        cmp byte [rsi], 0
        ;; Preserve the length of the reversed string in the rdx register. We will use this value when printing the string.
        mov rdx, rcx
        ;; If we reached the end of the input string, reverse it.
        je reverseString
        ;; Load a byte from the rsi to al register and move pointer to the next character in the string.
        lodsb
        ;; Save the character of the input string on the stack.
        push rax
        ;; Increase the counter that stores the length of our input string.
        inc rcx
        ;; Continue to go over the input string if we did not reach its end.
        jmp reverseStringAndPrint

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

;; Print the reversed string to the standard output.
printResult:
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
