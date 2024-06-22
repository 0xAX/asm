;; Definition of the `data` section
section .data
    ;; The content of the string `msg` with the value `hello world!`
    msg db      "hello, world!"

;; Definition of the text section
section .text
    ;; Reference to the entry point of our program
    global _start

;; Entry point
_start:
    ;; Number of the system call. The system call number 1 is `sys_write`.
    mov     rax, 1
    ;; The first argument of the `sys_write` system call.
    mov     rdi, 1
    ;; The second argument of the `sys_write` system call.
    mov     rsi, msg
    ;; The third argument of the `sys_write` system call.
    mov     rdx, 13
    ;; Call the `sys_write` system call.
    syscall
    ;; Number of the system call. The system call number 60 is `sys_exit`.
    mov    rax, 60
    ;; The first argument of the `sys_exit` system call.
    mov    rdi, 0
    ;; Call the `sys_exit` system call.
    syscall
