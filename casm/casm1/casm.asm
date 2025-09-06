;; Definition of the `data` section
section .data
    ;; String variable with the value `hello world!`
    msg db "hello, world!"

    ;; Reference to the C stdlib functions that we will use
    extern write, exit

;; Definition of the text section
section .text
    ;; Reference to the entry point of our program
    global _start

;; Entry point
_start:
    ;; Set the first argument of the `write` function to 1 (`stdout`).
    mov rdi, 1
    ;; Set the second argument of the `write` function to the reference of the `msg` variable.
    mov rsi, msg
    ;; Set the third argument to the length of the `msg` variable's value (13 bytes).
    mov rdx, 13
    ;; Call the `write` function.
    call write

    ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
    mov rdi, 0
    ;; Call the `exit` function
    call exit
