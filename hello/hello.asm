;; Definition of the `data` section
section .data
        ;; String variable with the value `hello world!`
        msg db "hello, world!"

;; Definition of the text section
section .text
        ;; Reference to the entry point of our program
        global _start

;; Entry point
_start:
        ;; Specify the number of the system call (1 is `sys_write`).
        mov rax, 1
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, 1
        ;; Set the second argument of `sys_write` to the reference of the `msg` variable.
        mov rsi, msg
        ;; Set the third argument of `sys_write` to the length of the `msg` variable's value (13 bytes).
        mov rdx, 13
        ;; Call the `sys_write` system call.
        syscall

        ;; Specify the number of the system call (60 is `sys_exit`).
        mov rax, 60
        ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
        mov rdi, 0
        ;; Call the `sys_exit` system call.
        syscall
